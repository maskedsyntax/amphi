import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final double playbackSpeed;
  final BoxFit videoFit;
  final double defaultVolume;

  SettingsState({
    this.playbackSpeed = 1.0,
    this.videoFit = BoxFit.contain,
    this.defaultVolume = 100.0,
  });

  SettingsState copyWith({
    double? playbackSpeed,
    BoxFit? videoFit,
    double? defaultVolume,
  }) {
    return SettingsState(
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      videoFit: videoFit ?? this.videoFit,
      defaultVolume: defaultVolume ?? this.defaultVolume,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _keySpeed = 'playback_speed';
  static const _keyFit = 'video_fit';
  static const _keyVolume = 'default_volume';

  @override
  SettingsState build() {
    _load();
    return SettingsState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      playbackSpeed: prefs.getDouble(_keySpeed) ?? 1.0,
      videoFit: BoxFit.values[prefs.getInt(_keyFit) ?? BoxFit.contain.index],
      defaultVolume: prefs.getDouble(_keyVolume) ?? 100.0,
    );
  }

  Future<void> setPlaybackSpeed(double speed) async {
    state = state.copyWith(playbackSpeed: speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySpeed, speed);
  }

  Future<void> setVideoFit(BoxFit fit) async {
    state = state.copyWith(videoFit: fit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFit, fit.index);
  }

  Future<void> setDefaultVolume(double volume) async {
    state = state.copyWith(defaultVolume: volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyVolume, volume);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
