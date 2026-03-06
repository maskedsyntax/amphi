import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/player_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/settings_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/themes.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _showPlaylist = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showShortcuts() {
    final themeMode = ref.read(themeProvider);
    final isDarkMode = ref.read(isDarkModeProvider);
    final isNeu = themeMode == AppThemeMode.neubrutalism;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: isNeu ? const RoundedRectangleBorder(side: BorderSide(width: 3)) : null,
        title: Text('KEYBOARD SHORTCUTS', 
          style: TextStyle(fontWeight: isNeu ? FontWeight.w900 : FontWeight.bold, letterSpacing: 1.2)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _shortcutRow('Space', 'Play / Pause', isNeu),
                _shortcutRow('← / →', 'Seek Backward / Forward', isNeu),
                _shortcutRow('↑ / ↓', 'Volume Up / Down', isNeu),
                _shortcutRow('L', 'Toggle Playlist', isNeu),
                _shortcutRow('S', 'Stop Playback', isNeu),
                _shortcutRow('N / P', 'Next / Previous Track', isNeu),
                _shortcutRow(',', 'Open Settings', isNeu),
                _shortcutRow('?', 'Show this Help', isNeu),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE', style: TextStyle(fontWeight: isNeu ? FontWeight.w900 : FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddUrlDialog() {
    final themeMode = ref.read(themeProvider);
    final isNeu = themeMode == AppThemeMode.neubrutalism;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: isNeu ? const RoundedRectangleBorder(side: BorderSide(width: 3)) : null,
        title: Text('OPEN NETWORK URL', style: TextStyle(fontWeight: isNeu ? FontWeight.w900 : FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'http://, rtsp://, etc.',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              ref.read(playlistProvider.notifier).addUrl(controller.text);
              Navigator.pop(context);
            },
            child: const Text('OPEN'),
          ),
        ],
      ),
    );
  }

  Widget _shortcutRow(String key, String action, bool isNeu) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNeu ? null : Colors.white10,
              border: isNeu ? Border.all(color: AppThemes.amphiBlue, width: 2) : Border.all(color: Colors.white24),
              borderRadius: isNeu ? BorderRadius.zero : BorderRadius.circular(6),
            ),
            child: Text(key, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppThemes.amphiBlue)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(action, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final notifier = ref.read(playerProvider.notifier);
      final playlist = ref.read(playlistProvider.notifier);

      switch (event.logicalKey) {
        case LogicalKeyboardKey.space:
          notifier.togglePlay();
          break;
        case LogicalKeyboardKey.arrowRight:
          notifier.stepForward();
          break;
        case LogicalKeyboardKey.arrowLeft:
          notifier.stepBackward();
          break;
        case LogicalKeyboardKey.arrowUp:
          notifier.volumeUp();
          break;
        case LogicalKeyboardKey.arrowDown:
          notifier.volumeDown();
          break;
        case LogicalKeyboardKey.keyS:
          notifier.stop();
          break;
        case LogicalKeyboardKey.keyN:
          playlist.next();
          break;
        case LogicalKeyboardKey.keyP:
          playlist.previous();
          break;
        case LogicalKeyboardKey.keyL:
          setState(() => _showPlaylist = !_showPlaylist);
          break;
        case LogicalKeyboardKey.comma:
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
          break;
        case LogicalKeyboardKey.slash:
          if (HardwareKeyboard.instance.isShiftPressed) {
            _showShortcuts();
          }
          break;
        case LogicalKeyboardKey.f1:
          _showShortcuts();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final playerNotifier = ref.read(playerProvider.notifier);
    final playlistState = ref.watch(playlistProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final settings = ref.watch(settingsProvider);

    final isNeu = themeMode == AppThemeMode.neubrutalism;
    final borderColor = isDarkMode ? Colors.white : Colors.black;

    FocusScope.of(context).requestFocus(_focusNode);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/logo.png', height: 40),
              const SizedBox(width: 16),
              const Text('AMPHI'),
            ],
          ),
          actions: [
            _ControlIconButton(
              icon: Icons.help_outline_rounded,
              onPressed: _showShortcuts,
              isNeu: isNeu,
              borderColor: borderColor,
              tooltip: 'Keyboard Shortcuts (?)',
            ),
            const SizedBox(width: 8),
            _ControlIconButton(
              icon: _showPlaylist ? Icons.featured_play_list_rounded : Icons.playlist_play_rounded,
              onPressed: () => setState(() => _showPlaylist = !_showPlaylist),
              isNeu: isNeu,
              borderColor: borderColor,
              tooltip: 'Toggle Playlist (L)',
            ),
            const SizedBox(width: 8),
            _ControlIconButton(
              icon: Icons.settings_rounded,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
              isNeu: isNeu,
              borderColor: borderColor,
              tooltip: 'Settings (,)',
            ),
            const SizedBox(width: 8),
            _ControlIconButton(
              icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              onPressed: () => ref.read(isDarkModeProvider.notifier).toggle(),
              isNeu: isNeu,
              borderColor: borderColor,
            ),
            const SizedBox(width: 8),
            _ControlIconButton(
              icon: isNeu ? Icons.auto_awesome_rounded : Icons.grid_view_rounded,
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              isNeu: isNeu,
              borderColor: borderColor,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isNeu ? 16 : 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: isNeu ? BorderRadius.zero : BorderRadius.circular(32),
                          border: isNeu ? Border.all(color: borderColor, width: 3) : null,
                          boxShadow: isNeu 
                              ? [BoxShadow(color: borderColor, offset: const Offset(8, 8))]
                              : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, spreadRadius: -5)],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Video(
                              controller: playerNotifier.videoController,
                              fit: settings.videoFit,
                            ),
                            if (playerState.isBuffering)
                              const CircularProgressIndicator(color: AppThemes.amphiBlue),
                            if (playerState.fileName == null)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_circle_fill_rounded, 
                                      size: 100, 
                                      color: isNeu ? AppThemes.amphiBlue : Colors.white24),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => playerNotifier.pickAndPlay(),
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('OPEN MEDIA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton.icon(
                                    onPressed: _showAddUrlDialog,
                                    icon: const Icon(Icons.link_rounded),
                                    label: const Text('OPEN URL'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(_formatDuration(playerState.position), style: _monoStyle(isNeu)),
                                Expanded(
                                  child: Slider(
                                    value: playerState.position.inSeconds.toDouble(),
                                    max: playerState.duration.inSeconds.toDouble() > 0 
                                      ? playerState.duration.inSeconds.toDouble() 
                                      : 1.0,
                                    onChanged: (val) => playerNotifier.seek(Duration(seconds: val.toInt())),
                                  ),
                                ),
                                Text(_formatDuration(playerState.duration), style: _monoStyle(isNeu)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playerState.fileName ?? 'READY TO PLAY',
                                        style: TextStyle(
                                          fontWeight: isNeu ? FontWeight.w900 : FontWeight.w600,
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (playerState.audioTracks.length > 1)
                                            _buildAudioTrackSelector(context, playerState, playerNotifier, isNeu),
                                          if (playerState.audioTracks.length > 1 && (playerState.subtitleTracks.isNotEmpty || true))
                                            const SizedBox(width: 12),
                                          _buildSubtitleSelector(context, playerState, playerNotifier, isNeu),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ControlButton(
                                      icon: Icons.skip_previous_rounded,
                                      onPressed: () => ref.read(playlistProvider.notifier).previous(),
                                      isNeu: isNeu,
                                      size: 40,
                                    ),
                                    const SizedBox(width: 8),
                                    _ControlButton(
                                      icon: Icons.stop_rounded,
                                      onPressed: () => playerNotifier.stop(),
                                      isNeu: isNeu,
                                      size: 40,
                                    ),
                                    const SizedBox(width: 16),
                                    _ControlButton(
                                      icon: playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      onPressed: () => playerNotifier.togglePlay(),
                                      isNeu: isNeu,
                                      isPrimary: true,
                                      size: 64,
                                    ),
                                    const SizedBox(width: 16),
                                    _ControlButton(
                                      icon: Icons.skip_next_rounded,
                                      onPressed: () => ref.read(playlistProvider.notifier).next(),
                                      isNeu: isNeu,
                                      size: 40,
                                    ),
                                  ],
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.volume_up_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 100,
                                        child: Slider(
                                          value: playerState.volume,
                                          max: 100.0,
                                          onChanged: (v) => playerNotifier.setVolume(v),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_showPlaylist)
              Container(
                width: 300,
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: borderColor, width: isNeu ? 3 : 1)),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PLAYLIST', style: TextStyle(fontWeight: isNeu ? FontWeight.w900 : FontWeight.bold, fontSize: 18)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_link_rounded, size: 20), 
                                onPressed: _showAddUrlDialog,
                                tooltip: 'Add Network URL',
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_box_rounded, size: 20), 
                                onPressed: () => playerNotifier.pickAndPlay(),
                                tooltip: 'Add Files',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: playlistState.items.length,
                        itemBuilder: (context, index) {
                          final item = playlistState.items[index];
                          final isSelected = playlistState.currentIndex == index;
                          return ListTile(
                            leading: Icon(
                              item.isNetwork ? Icons.cloud_queue_rounded : (item.isVideo ? Icons.movie_rounded : Icons.audiotrack_rounded), 
                              color: isSelected ? AppThemes.amphiBlue : null,
                            ),
                            title: Text(item.title, 
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? AppThemes.amphiBlue : null,
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () => ref.read(playlistProvider.notifier).setCurrentIndex(index),
                            trailing: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              onPressed: () => ref.read(playlistProvider.notifier).removeItem(index),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioTrackSelector(BuildContext context, AmphiPlayerState state, PlayerNotifier notifier, bool isNeu) {
    return InkWell(
      onTap: () {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(Offset.zero, ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );
        showMenu<AudioTrack>(
          context: context,
          position: position,
          items: state.audioTracks.map((track) {
            return PopupMenuItem(
              value: track,
              child: Text(
                '${track.language ?? 'Unknown'} (${track.title ?? track.id})',
                style: TextStyle(fontWeight: state.selectedAudioTrack == track ? FontWeight.bold : FontWeight.normal),
              ),
            );
          }).toList(),
        ).then((track) {
          if (track != null) notifier.setAudioTrack(track);
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language_rounded, size: 14, color: AppThemes.amphiBlue),
          const SizedBox(width: 4),
          Text(
            state.selectedAudioTrack?.language?.toUpperCase() ?? 
            state.selectedAudioTrack?.title ?? 'AUDIO',
            style: TextStyle(
              fontSize: 12, 
              fontWeight: isNeu ? FontWeight.w900 : FontWeight.bold,
              color: AppThemes.amphiBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleSelector(BuildContext context, AmphiPlayerState state, PlayerNotifier notifier, bool isNeu) {
    return InkWell(
      onTap: () {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(Offset.zero, ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );
        
        final List<PopupMenuEntry<dynamic>> items = [
          PopupMenuItem(
            value: 'load_external',
            child: Row(
              children: [
                const Icon(Icons.file_open_rounded, size: 18),
                const SizedBox(width: 8),
                const Text('Load External Subtitle'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: SubtitleTrack.no(),
            child: Text(
              'None',
              style: TextStyle(fontWeight: state.selectedSubtitleTrack == SubtitleTrack.no() ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          ...state.subtitleTracks.map((track) {
            return PopupMenuItem(
              value: track,
              child: Text(
                '${track.language ?? 'Unknown'} (${track.title ?? track.id})',
                style: TextStyle(fontWeight: state.selectedSubtitleTrack == track ? FontWeight.bold : FontWeight.normal),
              ),
            );
          }).toList(),
        ];

        showMenu<dynamic>(
          context: context,
          position: position,
          items: items,
        ).then((value) {
          if (value == 'load_external') {
            notifier.loadExternalSubtitle();
          } else if (value is SubtitleTrack) {
            notifier.setSubtitleTrack(value);
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.subtitles_rounded, size: 14, color: AppThemes.amphiBlue),
          const SizedBox(width: 4),
          Text(
            state.selectedSubtitleTrack?.language?.toUpperCase() ?? 
            state.selectedSubtitleTrack?.title ?? 'SUBS',
            style: TextStyle(
              fontSize: 12, 
              fontWeight: isNeu ? FontWeight.w900 : FontWeight.bold,
              color: AppThemes.amphiBlue,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _monoStyle(bool isNeu) => TextStyle(
    fontFamily: 'monospace',
    fontWeight: isNeu ? FontWeight.w900 : FontWeight.w500,
    fontSize: 12,
  );
}

class _ControlIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isNeu;
  final Color borderColor;
  final String? tooltip;

  const _ControlIconButton({
    required this.icon,
    required this.onPressed,
    required this.isNeu,
    required this.borderColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isNeu ? BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
      ) : null,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isNeu;
  final bool isPrimary;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.isNeu,
    this.isPrimary = false,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? AppThemes.amphiBlue : Colors.transparent;
    final onColor = isPrimary ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(isNeu ? 0 : size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: isNeu ? BoxShape.rectangle : BoxShape.circle,
          border: isNeu ? Border.all(color: borderColor, width: 3) : Border.all(color: onColor.withOpacity(0.1)),
          boxShadow: isNeu && isPrimary ? [BoxShadow(color: borderColor, offset: const Offset(4, 4))] : null,
        ),
        child: Icon(icon, color: onColor, size: size * 0.6),
      ),
    );
  }
}
