import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/themes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final isNeu = themeMode == AppThemeMode.neubrutalism;
    final borderColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('PLAYBACK', isNeu),
              _buildSettingCard(
                isNeu,
                borderColor,
                child: Column(
                  children: [
                    _buildSliderSetting(
                      label: 'Playback Speed',
                      value: settings.playbackSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 6,
                      displayValue: '${settings.playbackSpeed}x',
                      onChanged: (v) => ref.read(settingsProvider.notifier).setPlaybackSpeed(v),
                    ),
                    const Divider(height: 32),
                    _buildSliderSetting(
                      label: 'Default Volume',
                      value: settings.defaultVolume,
                      min: 0,
                      max: 100,
                      displayValue: '${settings.defaultVolume.toInt()}%',
                      onChanged: (v) => ref.read(settingsProvider.notifier).setDefaultVolume(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('VIDEO DISPLAY', isNeu),
              _buildSettingCard(
                isNeu,
                borderColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Aspect Ratio', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<BoxFit>(
                      value: settings.videoFit,
                      underline: const SizedBox(),
                      onChanged: (v) {
                        if (v != null) ref.read(settingsProvider.notifier).setVideoFit(v);
                      },
                      items: const [
                        DropdownMenuItem(value: BoxFit.contain, child: Text('Fit (Contain)')),
                        DropdownMenuItem(value: BoxFit.cover, child: Text('Fill (Cover)')),
                        DropdownMenuItem(value: BoxFit.fill, child: Text('Stretch')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('APPEARANCE', isNeu),
              _buildSettingCard(
                isNeu,
                borderColor,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: isDarkMode,
                      onChanged: (v) => ref.read(isDarkModeProvider.notifier).set(v),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('UI Theme Style', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(isNeu ? 'Neubrutalism' : 'Classic'),
                      trailing: IconButton(
                        icon: const Icon(Icons.swap_horiz_rounded),
                        onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isNeu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: isNeu ? FontWeight.w900 : FontWeight.w800,
          fontSize: 14,
          letterSpacing: 2,
          color: AppThemes.amphiBlue,
        ),
      ),
    );
  }

  Widget _buildSettingCard(bool isNeu, Color borderColor, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNeu ? null : Colors.white.withOpacity(0.05),
        borderRadius: isNeu ? BorderRadius.zero : BorderRadius.circular(20),
        border: isNeu ? Border.all(color: borderColor, width: 3) : Border.all(color: Colors.white10),
        boxShadow: isNeu ? [BoxShadow(color: borderColor, offset: const Offset(6, 6))] : null,
      ),
      child: child,
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(displayValue, style: const TextStyle(fontFamily: 'monospace', color: AppThemes.amphiBlue)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
