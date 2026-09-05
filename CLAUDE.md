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
- **…and it links but crashes without the call-site guards.** `app_bridge.m` only defines the
  `cocoa_*` app-bridge functions under `HAVE_SWIFT`, while `player/main.c` and `input/input.c`
  call them under `HAVE_COCOA` alone; the missing symbols link as `-undefined dynamic_lookup`
  imports that resolve to NULL, so the first `mpv_create()` segfaults at address 0. The same
  patch guards those call sites with `HAVE_COCOA && HAVE_SWIFT` (v0.8.2). After a version bump,
  check the built dylib for new dynamic-lookup imports (`nm`/otool: ordinal `DYNAMIC_LOOKUP`).
- **mbedtls must be built with `MBEDTLS_THREADING_C`** (`mk-pkg-mbedtls` sets it through
  `scripts/config.py`). ffmpeg ≥ 7 calls `psa_crypto_init()` on *every* TLS connection and mpv
  opens playlist, subtitles and segments concurrently; mbedtls only makes that init thread-safe
  behind that option, and without it the process aborts with a double free inside the entropy
  code. `LINK_WITH_PTHREAD` in their CMake only links pthread — it does not enable the option.
- **mbedtls must be ≥ 3.6, and fetched as the release asset.** 3.4.1 shipped with
  `MBEDTLS_SSL_PROTO_TLS1_3` off by default, so the Apple builds could only speak TLS 1.2 — the
  moment the media server's gateway went TLS 1.3-only (2026-09-05) every HLS open on iOS/macOS
  failed with "Failed to open", while the Dart side (platform TLS) kept working. 3.6 enables
  TLS 1.3 by default; 4.x is not an option because ffmpeg (9.0.1 and master) still calls
  `mbedtls_ssl_conf_rng`, which 4.0 removed. Since 3.6 the tree needs the `framework/` submodule
  (CMake refuses to configure without it and `scripts/config.py` imports from it), and only the
  `.tar.bz2` on the GitHub releases page bundles it — the `archive/refs/tags` tarball has an
  empty `framework/` directory.
- **fftools-ffi does not compile against ffmpeg 9** (it uses `av_stream_new_side_data` and
  friends) and its newest upstream revision is the one pinned here, so the encoders-gpl variant
  ships without it.
- Patches that upstream has since fixed were dropped: the HLS `cur_init_section` reset, the DASH
  base-URL escaping and the VP9 VideoToolbox decoder registration are all in ffmpeg 9.
- **`iossimulator` is a third os, not a flag on `ios`.** `oses.nix` lists it separately,
  `targets/pkgs.nix` builds it twice (arm64 + amd64) and `mk-out-xcframeworks` merges those
  slices into the *same* xcframework as the device build. Any per-os option block in
  `mk-pkg-*` that only tests `== oses.ios` therefore silently skips the simulator, which then
  falls back to whatever `DISABLE_ALL_OPTIONS` said. That shipped a simulator libmpv with no
  audio output at all through v0.8.2 (`-Daudiounit=disabled` never re-enabled): mpv logged
  "Could not open/initialize audio device -> no sound" and an audio-only file free-ran to EOF,
  because audio was its only clock. Video hid it — `plain-gl` is a `COMMON_VIDEO` option and
  applies to every os. When adding an option, decide explicitly whether the simulator wants it
  (`ios-gl` does not: there is no hardware decoding to interop with).
