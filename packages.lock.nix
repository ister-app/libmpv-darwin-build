{
  dav1d = {
    version = "1.2.1";
    url = "https://code.videolan.org/videolan/dav1d/-/archive/1.2.1/dav1d-1.2.1.tar.bz2";
    sha256 = "a4003623cdc0109dec3aac8435520aa3fb12c4d69454fa227f2658cdb6dab5fa";
  };
  ffmpeg = {
    version = "9.0.1";
    url = "https://ffmpeg.org/releases/ffmpeg-9.0.1.tar.xz";
    sha256 = "cf38e0e28c7e5605942c4a77755349b0145804a397af37eb1fb4c77cb237f635";
  };
  fftools-ffi = {
    version = "9b0d4da0";
    url = "https://github.com/moffatman/fftools-ffi/archive/9b0d4da026d9c830702ec043c1f1f98d407025af.tar.gz";
    sha256 = "mgf3ddt3yjmYBd2D0WeEnhgxKNjrEbjYnDx2t4YCfU8=";
  };
  freetype = {
    version = "2.13.2";
    url = "https://downloads.sourceforge.net/project/freetype/freetype2/2.13.2/freetype-2.13.2.tar.xz";
    sha256 = "12991c4e55c506dd7f9b765933e62fd2be2e06d421505d7950a132e4f1bb484d";
  };
  fribidi = {
    version = "1.0.13";
    url = "https://github.com/fribidi/fribidi/releases/download/v1.0.13/fribidi-1.0.13.tar.xz";
    sha256 = "7fa16c80c81bd622f7b198d31356da139cc318a63fc7761217af4130903f54a2";
  };
  harfbuzz = {
    version = "8.1.1";
    url = "https://github.com/harfbuzz/harfbuzz/archive/8.1.1.tar.gz";
    sha256 = "b16e6bc0fc7e6a218583f40c7d201771f2e3072f85ef6e9217b36c1dc6b2aa25";
  };
  libass = {
    version = "0.17.1";
    url = "https://github.com/libass/libass/releases/download/0.17.1/libass-0.17.1.tar.xz";
    sha256 = "f0da0bbfba476c16ae3e1cfd862256d30915911f7abaa1b16ce62ee653192784";
  };
  libogg = {
    version = "1.3.5";
    url = "https://github.com/xiph/ogg/releases/download/v1.3.5/libogg-1.3.5.tar.gz";
    sha256 = "0eb4b4b9420a0f51db142ba3f9c64b333f826532dc0f48c6410ae51f4799b664";
  };
  libpng = {
    version = "1.6.40";
    url = "https://github.com/pnggroup/libpng/archive/v1.6.40.tar.gz";
    sha256 = "62d25af25e636454b005c93cae51ddcd5383c40fa14aa3dae8f6576feb5692c2";
  };
  libpngPatch = {
    version = "1.6.40-1";
    url = "https://wrapdb.mesonbuild.com/v2/libpng_1.6.40-1/get_patch";
    sha256 = "bad558070e0a82faa5c0ae553bcd12d49021fc4b628f232a8e58c3fbd281aae1";
  };
  libplacebo = {
    version = "7.360.1";
    url = "https://github.com/haasn/libplacebo/archive/refs/tags/v7.360.1.tar.gz";
    sha256 = "d05fdf90bea2f629eaa2d115e909fd356388ac639e54f77b87a018a6d76224bd";
  };
  # libplacebo keeps these as git submodules; the release tarball has none of
  # them, so they are fetched separately and copied into 3rdparty/.
  libplaceboGlad = {
    version = "73db193f";
    url = "https://github.com/Dav1dde/glad/archive/73db193f853e2ee079bf3ca8a64aa2eaf6459043.tar.gz";
    sha256 = "33dbeae44d8315ece57e14eba4b1b4a02ac5406d1c4f49cd20048c91522a6b9a";
  };
  libplaceboJinja = {
    version = "15206881";
    url = "https://github.com/pallets/jinja/archive/15206881c006c79667fe5154fe80c01c65410679.tar.gz";
    sha256 = "b88a20dcc2e34072fcf4159325bc6c34cd4b29a81a8b83d15d2f28ba561da296";
  };
  libplaceboMarkupsafe = {
    version = "297fc8e3";
    url = "https://github.com/pallets/markupsafe/archive/297fc8e356e6836a62087949245d09a28e9f1b13.tar.gz";
    sha256 = "da7c010c9c81a66ac73036558c1fcb6212b50482f43211cd1254035b94f82414";
  };
  libplaceboVulkanHeaders = {
    version = "450bd223";
    url = "https://github.com/KhronosGroup/Vulkan-Headers/archive/450bd2232225d6c7728a4108055ac2e37cef6475.tar.gz";
    sha256 = "26df9841c30806a994e2fdf42f7c87bcb1ced9db9a06033469123939fb3fa075";
  };
  libplaceboFastFloat = {
    version = "97b54ca9";
    url = "https://github.com/fastfloat/fast_float/archive/97b54ca9e75f5303507699d27c6b4f4efe4641a1.tar.gz";
    sha256 = "2b132274539286e41f37857cac22aa8441d21bd86d55de825a3342b149f66801";
  };
  libvorbis = {
    version = "1.3.7";
    url = "https://github.com/xiph/vorbis/releases/download/v1.3.7/libvorbis-1.3.7.tar.gz";
    sha256 = "0e982409a9c3fc82ee06e08205b1355e5c6aa4c36bca58146ef399621b0ce5ab";
  };
  libvpx = {
    version = "1.13.0+1";
    url = "https://gitlab.freedesktop.org/gstreamer/meson-ports/libvpx/-/archive/90d26fac0d895969a82cd873ad36e39737104c44/libvpx-v1.13.0.tar.gz";
    sha256 = "4f872ad2709d17b848b3588231495e432c42b9263731b9121fa210a3c5a893ff";
  };
  libx264 = {
    version = "a8b68ebf";
    url = "https://code.videolan.org/videolan/x264/-/archive/a8b68ebfaa68621b5ac8907610d3335971839d52/libx264-a8b68ebfaa68621b5ac8907610d3335971839d52.tar.gz";
    sha256 = "164688b63f11a6e4f6d945057fc5c57d5eefb97973d0029fb0303744e10839ff";
  };
  libxml2 = {
    version = "2.11.5";
    url = "https://download.gnome.org/sources/libxml2/2.11/libxml2-2.11.5.tar.xz";
    sha256 = "3727b078c360ec69fa869de14bd6f75d7ee8d36987b071e6928d4720a28df3a6";
  };
  mbedtls = {
    # The release asset, not the GitHub archive: since 3.6 the build needs the
    # `framework/` submodule (CMake fails without it, scripts/config.py imports
    # from it), which only the asset on the releases page bundles.
    version = "3.6.7";
    url = "https://github.com/Mbed-TLS/mbedtls/releases/download/mbedtls-3.6.7/mbedtls-3.6.7.tar.bz2";
    sha256 = "a7e8bcbec0e6f761b4af24f25677626b35f762f68eef79c08677a363212d11f6";
  };
  mpv = {
    version = "0.41.0";
    url = "https://github.com/mpv-player/mpv/archive/refs/tags/v0.41.0.tar.gz";
    sha256 = "ee21092a5ee427353392360929dc64645c54479aefdb5babc5cfbb5fad626209";
  };
  uchardet = {
    version = "0.0.8";
    url = "https://www.freedesktop.org/software/uchardet/releases/uchardet-0.0.8.tar.xz";
    sha256 = "e97a60cfc00a1c147a674b097bb1422abd9fa78a2d9ce3f3fdcc2e78a34ac5f0";
  };
}
