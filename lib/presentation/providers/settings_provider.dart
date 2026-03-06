import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  SettingsState build() {
    return SettingsState();
  }

  void setPlaybackSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
  }

  void setVideoFit(BoxFit fit) {
    state = state.copyWith(videoFit: fit);
  }

  void setDefaultVolume(double volume) {
    state = state.copyWith(defaultVolume: volume);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
