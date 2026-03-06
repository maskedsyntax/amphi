# Amphi Player 📽️

Amphi is a modern, high-performance desktop media player designed for Linux, Windows, and macOS. It combines a robust playback engine with a unique, toggleable UI experience, allowing users to switch between a refined **Classic** aesthetic and a bold **Neubrutalist** style.

## ✨ Features

### 🚀 High-Performance Playback
- Powered by `media_kit` and `libmpv` for efficient, low-latency decoding.
- Supports a wide range of formats: MP4, MKV, AVI, MOV, MP3, WAV, OGG, and more.
- Gapless playback and smooth seeking (<300ms latency).

### 🎨 Dual-Path UI Architecture
- **Classic Mode:** Elegant, subtle gradients, rounded controls, and traditional player aesthetics.
- **Neubrutalism Mode:** High-contrast, grid-based, bold typography, and functional "brutal" shadows.
- **Light/Dark Support:** Seamlessly transitions between light and dark modes in both UI styles.

### 📋 Advanced Media Handling
- **Playlist System:** Side-panel management with drag-to-add support and auto-advance.
- **Multi-Language Support:** Easily switch between available audio tracks (languages) in real-time.
- **Subtitle Integration:** Support for embedded tracks and external `.srt`, `.ass`, `.vtt` loading.
- **Persistence:** Automatically saves your theme, settings, and playlist across sessions.

### ⚙️ Customizable Experience
- **Playback Controls:** Adjust playback speed (0.5x – 2.0x) and volume.
- **Video Scaling:** Toggle between Fit (Contain), Fill (Cover), and Stretch (Fill) modes.
- **Native Experience:** Integrated window management and native file pickers.

---

## ⌨️ Keyboard Shortcuts

Amphi is designed for power users with a full suite of shortcuts:

| Key | Action |
|-----|--------|
| `Space` | Play / Pause |
| `→` / `←` | Seek Forward / Backward (10s) |
| `↑` / `↓` | Volume Up / Down |
| `L` | Toggle Playlist Panel |
| `S` | Stop Playback |
| `N` / `P` | Next / Previous Track |
| `,` (Comma) | Open Settings |

---

## 🛠️ Getting Started

### Prerequisites

#### Linux (Debian/Ubuntu)
```bash
sudo apt install libmpv-dev libavcodec-dev libavformat-dev libavutil-dev libswresample-dev libswscale-dev
```

#### Linux (Arch)
```bash
sudo pacman -S mpv ffmpeg base-devel clang cmake ninja pkgconf xdg-desktop-portal xdg-desktop-portal-gtk
```

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/maskedsyntax/amphi.git
   cd amphi
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application (Natively):**
   ```bash
   flutter run -d linux
   ```

---

## 🏗️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Desktop)
- **Media Core:** [media_kit](https://pub.dev/packages/media_kit) (libmpv + FFmpeg)
- **State Management:** [Riverpod 2.x/3.x](https://riverpod.dev/) (Notifier/Provider)
- **Persistence:** [shared_preferences](https://pub.dev/packages/shared_preferences)
- **UI Architecture:** Custom Material 3 + Neubrutalist Implementation

---

## 🗺️ Roadmap

- [x] **Phase 1: MVP** - High-performance core and initial UI skeleton.
- [x] **Phase 2: Intermediate** - Playlists, Shortcuts, Multi-track, and Persistence.
- [ ] **Phase 3: Advanced** - Network streaming (HLS/DASH), EQ filters, and Media Library scanning.
- [ ] **Phase 4: Polish** - Casting (DLNA/Chromecast) and Plugin system.

---

## 📄 License
Amphi is developed as an open-source high-performance media player prototype.
