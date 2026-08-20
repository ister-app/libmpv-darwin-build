# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

## What this is

`ister-app`'s fork of `media-kit/libmpv-darwin-build`: it cross-compiles libmpv and its
dependencies into xcframeworks for macOS, iOS and the iOS simulator. The Ister player consumes
the result through `ister-app/media-kit`'s `libs/macos` and `libs/ios` packages.

Upstream sat on **mpv 0.36.0** (2023), which predates `--video-crop`; this fork builds
**mpv 0.41.0 against ffmpeg 9.0.1** so the player's server-detected crop works on Apple platforms.

## Build

`nix` does everything; `make` is a thin wrapper (see `Makefile`). CI (`.github/workflows/ci.yaml`)
runs on a `macos-15` runner with Xcode 16.1 and builds every target.

- push to `main` → build only
- push a **tag** → build **and** attach the archives to a release; the tag name becomes the
  version in every filename (`libmpv-xcframeworks_v0.8.1_macos-universal-video-default.tar.gz`)

There is no way to build this on Linux. Iterate through CI, and read failures with
`gh run view -R ister-app/libmpv-darwin-build --log-failed <run-id>`.

## Versions

All dependency versions live in `packages.lock.nix` (url + hex sha256 of the tarball, verified by
`builtins.fetchurl`). Compute a new hash with `sha256sum` on the downloaded file — no nix needed.

## Things that cost time to find out

- **mpv ≥ 0.37 requires libplacebo, ≥ 0.41 requires libass unconditionally.** The old
  `mpv-remove-libass.patch` for the audio variant is therefore gone: audio builds now link libass
  and its font stack (freetype, fribidi, harfbuzz, libpng) too, which the consuming
  `Package.swift` must list as binary targets.
- **libplacebo's release tarball carries no submodules.** `glad`, `jinja`, `markupsafe`,
  `fast_float` *and* `Vulkan-Headers` are locked separately and copied into `3rdparty/`.
  Vulkan-Headers is needed even with `-Dvulkan=disabled`: `src/vulkan/stubs.c` and the public
  `libplacebo/vulkan.h` include `<vulkan/vulkan.h>` regardless.
- **nix rejects world-writable build outputs** ("suspicious ownership or permission"). Never
  `chmod -R 777` into `$out`; build in the sandbox and `cp -r` into `$out`, which applies the umask.
- **meson's install step shells out to `otool`** on darwin to rewrite rpaths, so any package that
  installs a dylib needs the xctoolchain wrapper in `nativeBuildInputs`.
- **mpv's meson errors on unknown options.** After a version bump, regenerate the
  `DISABLE_ALL_OPTIONS` list in `mk-pkg-mpv` from that release's `meson.options` instead of
  patching it by hand — 11 options disappeared and 17 appeared between 0.36 and 0.41.
- **cocoa without swift-build does not compile in 0.41**: `player/clipboard/clipboard-mac.m` uses
  the Swift bridge header without a `HAVE_SWIFT` guard. `patches/mpv-cocoa-without-swift.patch`
  drops that backend. Turning cocoa off instead is not an option — `videotoolbox-gl` requires
  `gl-cocoa`, so it would cost hardware decoding interop.
- **mbedtls must be built with `MBEDTLS_THREADING_C`** (`mk-pkg-mbedtls` sets it through
  `scripts/config.py`). ffmpeg ≥ 7 calls `psa_crypto_init()` on *every* TLS connection and mpv
  opens playlist, subtitles and segments concurrently; mbedtls only makes that init thread-safe
  behind that option, and without it the process aborts with a double free inside the entropy
  code. `LINK_WITH_PTHREAD` in their CMake only links pthread — it does not enable the option.
- **fftools-ffi does not compile against ffmpeg 9** (it uses `av_stream_new_side_data` and
  friends) and its newest upstream revision is the one pinned here, so the encoders-gpl variant
  ships without it.
- Patches that upstream has since fixed were dropped: the HLS `cur_init_section` reset, the DASH
  base-URL escaping and the VP9 VideoToolbox decoder registration are all in ffmpeg 9.
