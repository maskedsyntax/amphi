# Amphi Player

A modern, high-performance media player for Linux, Windows, and macOS.

## Features (Phase 1 MVP)

- **High-Performance Playback:** Powered by `media_kit` (libmpv).
- **Dual Theme Support:** Toggle between **Classic** (elegant) and **Neubrutalism** (raw/bold) styles.
- **Light/Dark Mode:** Full support for both themes.
- **Local Media Support:** Play MP3, WAV, OGG, MP4, MKV, AVI.
- **Controls:** Play, Pause, Stop, Seek, Volume.
- **Modern UI:** Clean, responsive desktop interface.

## Tech Stack

- **Framework:** Flutter (Desktop)
- **State Management:** Riverpod 2.x
- **Media Core:** media_kit (FFmpeg + libmpv)
- **Theming:** Custom Material 3 + Neubrutalism implementation.

## Prerequisites

### Linux
**Debian/Ubuntu:**
```bash
sudo apt install libmpv-dev libavcodec-dev libavformat-dev libavutil-dev libswresample-dev libswscale-dev
```

**Arch Linux:**
```bash
sudo pacman -S mpv ffmpeg base-devel clang cmake ninja pkgconf
```

### Windows/macOS
Standard Flutter desktop requirements.

## Getting Started

1. Clone the repository.
2. Run `flutter pub get`.
3. Run `flutter run`.

## Roadmap

- [x] Phase 1: MVP (Core Playback & Themes)
- [ ] Phase 2: Intermediate (Playlists, Shortcuts, Subtitles)
- [ ] Phase 3: Advanced (Streaming, Filters, Media Library)
