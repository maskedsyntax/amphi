# Amphi Player TODO List

## 🟢 Phase 1: UX & Essential Polish
- [x] **Auto-Hide Controls**: Implement "Ghost Mode" where the UI fades out after 3 seconds of mouse inactivity.
- [x] **Drag & Drop**: Allow dragging files/folders directly from the OS into the window to queue them.
- [x] **External Subtitles**: Add a dialog to manually load `.srt`, `.ass`, or `.vtt` files.
- [x] **Double-Click Fullscreen**: Add mouse gesture support to toggle fullscreen mode.
- [x] **Global Hotkeys**: 
    - `Left/Right Arrows`: Skip 5s
    - `Up/Down Arrows`: Volume +/- 5%
    - `M`: Mute toggle

## 🟡 Phase 2: Advanced Playback & Sync
- [x] **Audio Synchronization**: Add an offset control (e.g., +/- 100ms) to fix delayed audio.
- [x] **Subtitle Synchronization**: Add an offset control to realign subtitles with the dialogue.
- [x] **Playback Speed**: Add a menu to adjust speed from 0.5x to 4.0x.
- [x] **Video Fit Modes**: Options for "Stretch to Fill", "Crop to Fill", and "Original Ratio".

## 🔵 Phase 3: Power User Utilities
- [x] **Screenshot Utility**: One-click high-quality frame capture saved to Desktop.
- [x] **Stay on Top**: A "Pin" mode to keep Amphi above all other windows.
- [x] **Network Streams**: Support for "Open URL" (YouTube, Twitch, HLS) via `yt-dlp` integration.
- [ ] **Audio Equalizer**: A simple 10-band UI to tweak sound profiles.

## 🟣 Phase 4: Distribution & Platform Support
- [ ] **macOS Bundling**: Script to create a standalone, portable `Amphi.app`.
- [ ] **Linux Packaging**: Create an `AppImage` or `Flatpak`.
- [ ] **Windows Port**: Finalize CMake and MPV linking for Windows 10/11.
