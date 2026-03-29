# Amphi Player

Amphi Player is a high performance desktop media player designed for a minimalist and efficient user experience. It combines the robust media engine of libmpv with a modern, responsive interface built using Qt 6 and C++.

## Key Features

### High Performance Playback
The product utilizes hardware acceleration and OpenGL to ensure smooth rendering of high resolution video, including support for demanding 10-bit HEVC and high bitrate media files.

### Minimalist User Interface
The interface is designed to be compact and unobtrusive. It features a translucent, glass-like aesthetic that adapts to both light and dark system themes.

### Comprehensive Format Support
Amphi Player supports a wide variety of video and audio formats through its integration with libmpv. This includes standard formats such as MP4 and AVI, as well as complex MKV files with multiple streams.

### Advanced Media Management
- Track Selection: Easily switch between multiple audio streams and embedded subtitle tracks.
- External Subtitles: Support for loading external subtitle files via drag and drop or manual selection.
- Playlist Queue: A toggleable side panel allows users to manage a queue of media files for continuous playback.
- Drag and Drop: Support for adding files directly from the operating system into the application.

### Specialized User Experience
- Automatic Interface Hiding: Controls automatically fade out during playback to provide a distraction-free viewing experience.
- Global Hotkeys: Efficient keyboard shortcuts for volume control, seeking, and playback toggling.
- Gesture Support: Double click the video area to toggle fullscreen mode.

## Technical Architecture

Amphi Player is built using C++ 17 and the Qt 6 framework. It leverages libmpv for core playback functionality, ensuring low latency and high compatibility across desktop platforms.

## Platform Support

The application is developed for macOS and Linux environments. Windows support is planned for future updates.
