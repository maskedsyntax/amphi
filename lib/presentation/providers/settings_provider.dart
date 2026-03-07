import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final double playbackSpeed;
  final BoxFit videoFit;
  final double defaultVolume;
  
  // Video Filters
  final double brightness;
  final double contrast;
  final double saturation;
  final double hue;

  // Audio EQ (10 bands: 31, 62, 125, 250, 500, 1k, 2k, 4k, 8k, 16k Hz)
  // Values are in dB: -10.0 to 10.0
  final List<double> equalizerBands;

  SettingsState({
    this.playbackSpeed = 1.0,
    this.videoFit = BoxFit.contain,
    this.defaultVolume = 100.0,
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.hue = 0.0,
    this.equalizerBands = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  });

  SettingsState copyWith({
    double? playbackSpeed,
    BoxFit? videoFit,
    double? defaultVolume,
    double? brightness,
    double? contrast,
    double? saturation,
    double? hue,
    List<double>? equalizerBands,
  }) {
    return SettingsState(
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      videoFit: videoFit ?? this.videoFit,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      hue: hue ?? this.hue,
      equalizerBands: equalizerBands ?? this.equalizerBands,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _keySpeed = 'playback_speed';
  static const _keyFit = 'video_fit';
  static const _keyVolume = 'default_volume';
  static const _keyBrightness = 'video_brightness';
  static const _keyContrast = 'video_contrast';
  static const _keySaturation = 'video_saturation';
  static const _keyHue = 'video_hue';
  static const _keyEQ = 'audio_eq_bands';

  @override
  SettingsState build() {
    _load();
    return SettingsState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final eqStrings = prefs.getStringList(_keyEQ);
    final eqBands = eqStrings?.map((e) => double.tryParse(e) ?? 0.0).toList() ?? 
                    const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

    state = SettingsState(
      playbackSpeed: prefs.getDouble(_keySpeed) ?? 1.0,
      videoFit: BoxFit.values[prefs.getInt(_keyFit) ?? BoxFit.contain.index],
      defaultVolume: prefs.getDouble(_keyVolume) ?? 100.0,
      brightness: prefs.getDouble(_keyBrightness) ?? 0.0,
      contrast: prefs.getDouble(_keyContrast) ?? 0.0,
      saturation: prefs.getDouble(_keySaturation) ?? 0.0,
      hue: prefs.getDouble(_keyHue) ?? 0.0,
      equalizerBands: eqBands,
    );
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  void setPlaybackSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
    _saveDouble(_keySpeed, speed);
  }

  void setVideoFit(BoxFit fit) async {
    state = state.copyWith(videoFit: fit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFit, fit.index);
  }

  void setDefaultVolume(double volume) {
    state = state.copyWith(defaultVolume: volume);
    _saveDouble(_keyVolume, volume);
  }

  void setBrightness(double value) {
    state = state.copyWith(brightness: value);
    _saveDouble(_keyBrightness, value);
  }

  void setContrast(double value) {
    state = state.copyWith(contrast: value);
    _saveDouble(_keyContrast, value);
  }

  void setSaturation(double value) {
    state = state.copyWith(saturation: value);
    _saveDouble(_keySaturation, value);
  }

  void setHue(double value) {
    state = state.copyWith(hue: value);
    _saveDouble(_keyHue, value);
  }

  void setEqBand(int index, double value) async {
    final newBands = [...state.equalizerBands];
    newBands[index] = value;
    state = state.copyWith(equalizerBands: newBands);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyEQ, newBands.map((e) => e.toString()).toList());
  }

  void resetFilters() {
    state = state.copyWith(brightness: 0.0, contrast: 0.0, saturation: 0.0, hue: 0.0);
    _saveDouble(_keyBrightness, 0.0);
    _saveDouble(_keyContrast, 0.0);
    _saveDouble(_keySaturation, 0.0);
    _saveDouble(_keyHue, 0.0);
  }

  void resetEQ() async {
    final zeroBands = List<double>.filled(10, 0.0);
    state = state.copyWith(equalizerBands: zeroBands);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyEQ, zeroBands.map((e) => e.toString()).toList());
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
