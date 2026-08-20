{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "mbedtls";
  packageLock = (import ../../../packages.lock.nix).${name};
  inherit (packageLock) version;

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };

  pname = import ../../utils/name/package.nix name;
  src = callPackage ../../utils/fetch-tarball/default.nix {
    name = "${pname}-source-${version}";
    inherit (packageLock) url sha256;
  };
  patchedSource =
    pkgs.runCommand "${pname}-patched-source-${version}"
      { nativeBuildInputs = [ pkgs.python3 ]; }
      ''
        mkdir -p $out/subprojects/mbedtls
        cp -r ${src}/* $out/subprojects/mbedtls/
        chmod -R u+w $out/subprojects/mbedtls
        cp ${./meson.build} $out/meson.build

        # ffmpeg >= 7 calls psa_crypto_init() on every TLS connection, and mpv
        # opens the playlist, the subtitle rendition and the segments from
        # several threads at once. PSA's global init is only thread-safe with
        # MBEDTLS_THREADING_C (see docs/architecture/psa-thread-safety), which
        # the default config ships commented out; without it the concurrent
        # init double-frees inside the entropy code.
        python3 $out/subprojects/mbedtls/scripts/config.py \
          -f $out/subprojects/mbedtls/include/mbedtls/mbedtls_config.h \
          set MBEDTLS_THREADING_C
        python3 $out/subprojects/mbedtls/scripts/config.py \
          -f $out/subprojects/mbedtls/include/mbedtls/mbedtls_config.h \
          set MBEDTLS_THREADING_PTHREAD
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
    pkgs.cmake
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
    pkgs.python3
  ];
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out
  '';
  buildPhase = ''
    meson compile -vC build
  '';
  installPhase = ''
    # create output layout
    mkdir -p $out/{include,lib}
    mkdir -p $out/include/{mbedtls,psa}
    mkdir -p $out/lib/pkgconfig

    # install headers
    cp $src/subprojects/mbedtls/include/mbedtls/*.h $out/include/mbedtls/
    cp $src/subprojects/mbedtls/include/psa/*.h $out/include/psa/

    # install libs
    find build -type f -name '*.dylib' -exec sh -c 'cp {} $out/lib/' \;

    # install pkgconfig file
    cp ${./mbedtls.pc.in} $out/lib/pkgconfig/mbedtls.pc
    sed -i "s|\''${PREFIX}|$out|g" $out/lib/pkgconfig/mbedtls.pc
    sed -i "s|\''${VERSION}|${version}|g" $out/lib/pkgconfig/mbedtls.pc
  '';
}
