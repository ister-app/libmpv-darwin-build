{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "libplacebo";
  packageLock = (import ../../../packages.lock.nix).${name};
  inherit (packageLock) version;
  locks = import ../../../packages.lock.nix;

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };
  xctoolchainInstallNameTool = callPackage ../../utils/xctoolchain/install-name-tool.nix { };

  pname = import ../../utils/name/package.nix name;
  fetch =
    lock: suffix:
    callPackage ../../utils/fetch-tarball/default.nix {
      name = "${pname}-source-${suffix}-${lock.version}";
      inherit (lock) url sha256;
    };
  src = fetch packageLock "main";

  # `3rdparty/*` are git submodules upstream and are absent from the release
  # tarball; the OpenGL renderer's loader is generated at build time from glad
  # (which imports jinja/markupsafe from PYTHONPATH — see meson.build's
  # `python_env`), and src/meson.build picks up fast_float's headers.
  glad = fetch locks.libplaceboGlad "glad";
  jinja = fetch locks.libplaceboJinja "jinja";
  markupsafe = fetch locks.libplaceboMarkupsafe "markupsafe";
  fastFloat = fetch locks.libplaceboFastFloat "fast-float";
  # Needed even with -Dvulkan=disabled: src/vulkan/stubs.c and the public
  # libplacebo/vulkan.h include <vulkan/vulkan.h> unconditionally.
  vulkanHeaders = fetch locks.libplaceboVulkanHeaders "vulkan-headers";

  patchedSource = pkgs.runCommand "${pname}-patched-source-${version}" { } ''
    cp -r ${src} src
    chmod -R u+w src

    for dir in glad jinja markupsafe fast_float Vulkan-Headers; do
      rm -rf src/3rdparty/$dir
      mkdir -p src/3rdparty/$dir
    done
    cp -r ${glad}/* src/3rdparty/glad/
    cp -r ${jinja}/* src/3rdparty/jinja/
    cp -r ${markupsafe}/* src/3rdparty/markupsafe/
    cp -r ${fastFloat}/* src/3rdparty/fast_float/
    cp -r ${vulkanHeaders}/* src/3rdparty/Vulkan-Headers/

    # Copy rather than move: `cp` applies the umask, and nix rejects a
    # world-writable build output ("suspicious ownership or permission").
    cp -r src $out
  '';
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${version}";
  pname = pname;
  inherit version;
  src = patchedSource;
  dontUnpack = true;
  enableParallelBuilding = true;
  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
    pkgs.python3
    xctoolchainInstallNameTool
  ];
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out \
      `# mpv only needs the OpenGL renderer here; everything else would` \
      `# drag in Vulkan/Direct3D/shader-compiler toolchains we do not ship.` \
      -Dopengl=enabled \
      -Dgl-proc-addr=disabled \
      -Dvulkan=disabled \
      -Dvk-proc-addr=disabled \
      -Dd3d11=disabled \
      -Dglslang=disabled \
      -Dshaderc=disabled \
      -Dlcms=disabled \
      -Ddovi=disabled \
      -Dlibdovi=disabled \
      -Dunwind=disabled \
      -Dxxhash=disabled \
      -Ddemos=false \
      -Dtests=false \
      -Dbench=false \
      -Dfuzz=false
  '';
  buildPhase = ''
    meson compile -vC build
  '';
  installPhase = ''
    meson install -C build

    # Rename libplacebo.<soversion>.dylib -> libplacebo.dylib and give it an
    # @rpath install name, like the other packages here do.
    for file in $out/lib/libplacebo*.dylib; do
      [ -L "$file" ] && continue
      install_name_tool -id @rpath/$(basename $file) $file
    done
  '';
}
