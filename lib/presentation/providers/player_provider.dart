import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:file_picker/file_picker.dart';
import 'playlist_provider.dart';
import 'settings_provider.dart';

class AmphiPlayerState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final double volume;
  final String? fileName;
  final List<AudioTrack> audioTracks;
  final AudioTrack? selectedAudioTrack;
  final List<SubtitleTrack> subtitleTracks;
  final SubtitleTrack? selectedSubtitleTrack;

  AmphiPlayerState({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isBuffering,
    required this.volume,
    this.fileName,
    this.audioTracks = const [],
    this.selectedAudioTrack,
    this.subtitleTracks = const [],
    this.selectedSubtitleTrack,
  });

  factory AmphiPlayerState.initial() => AmphiPlayerState(
        position: Duration.zero,
        duration: Duration.zero,
        isPlaying: false,
        isBuffering: false,
        volume: 100.0,
      );

  AmphiPlayerState copyWith({
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isBuffering,
    double? volume,
    String? fileName,
    List<AudioTrack>? audioTracks,
    AudioTrack? selectedAudioTrack,
    List<SubtitleTrack>? subtitleTracks,
    SubtitleTrack? selectedSubtitleTrack,
  }) {
    return AmphiPlayerState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      fileName: fileName ?? this.fileName,
      audioTracks: audioTracks ?? this.audioTracks,
      selectedAudioTrack: selectedAudioTrack ?? this.selectedAudioTrack,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
      selectedSubtitleTrack: selectedSubtitleTrack ?? this.selectedSubtitleTrack,
    );
  }
}

class PlayerNotifier extends Notifier<AmphiPlayerState> {
  late final Player player;
  late final VideoController videoController;

  @override
  AmphiPlayerState build() {
    player = Player();
    videoController = VideoController(player);

    player.stream.position.listen((pos) => state = state.copyWith(position: pos));
    player.stream.duration.listen((dur) => state = state.copyWith(duration: dur));
    player.stream.playing.listen((isPlaying) => state = state.copyWith(isPlaying: isPlaying));
    player.stream.volume.listen((vol) => state = state.copyWith(volume: vol));
    player.stream.buffering.listen((isBuffering) => state = state.copyWith(isBuffering: isBuffering));
    
    // Track handling
    player.stream.tracks.listen((tracks) {
      state = state.copyWith(
        audioTracks: tracks.audio,
        selectedAudioTrack: player.state.track.audio,
        subtitleTracks: tracks.subtitle,
        selectedSubtitleTrack: player.state.track.subtitle,
      );
    });

    player.stream.track.listen((track) {
      state = state.copyWith(
        selectedAudioTrack: track.audio,
        selectedSubtitleTrack: track.subtitle,
      );
    });

    player.stream.completed.listen((completed) {
      if (completed) {
        ref.read(playlistProvider.notifier).next();
      }
    });

    ref.listen(playlistProvider, (previous, next) {
      if (next.currentIndex != -1 && 
          (previous == null || previous.currentIndex != next.currentIndex)) {
        final item = next.items[next.currentIndex];
        _playItem(item);
      }
    });

    ref.listen(settingsProvider, (previous, next) {
      if (previous?.playbackSpeed != next.playbackSpeed) {
        player.setRate(next.playbackSpeed);
      }
      if (previous?.defaultVolume != next.defaultVolume && state.fileName == null) {
        player.setVolume(next.defaultVolume);
      }
    });

    ref.onDispose(() => player.dispose());

    return AmphiPlayerState.initial();
  }

  Future<void> _playItem(PlaylistItem item) async {
    final settings = ref.read(settingsProvider);
    await player.open(Media(item.path));
    await player.setRate(settings.playbackSpeed);
    state = state.copyWith(fileName: item.title);
  }

  Future<void> setAudioTrack(AudioTrack track) async {
    await player.setAudioTrack(track);
  }

  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    await player.setSubtitleTrack(track);
  }

  Future<void> loadExternalSubtitle() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'ass', 'vtt', 'ssa'],
    );

    if (result != null && result.files.single.path != null) {
      // media_kit allows adding external subtitles via SubtitleTrack.uri
      final track = SubtitleTrack.uri(
        result.files.single.path!,
        title: result.files.single.name,
        language: 'External',
      );
      await player.setSubtitleTrack(track);
    }
  }

  Future<void> pickAndPlay() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'mp4', 'mkv', 'avi', 'mov'],
      allowMultiple: true,
    );

    if (result != null && result.paths.isNotEmpty) {
      final validPaths = result.paths.whereType<String>().toList();
      ref.read(playlistProvider.notifier).addItems(validPaths);
    }
  }

  Future<void> togglePlay() async => await player.playOrPause();
  Future<void> stop() async => await player.stop();
  Future<void> seek(Duration position) async => await player.seek(position);
  Future<void> setVolume(double volume) async => await player.setVolume(volume);
  
  void stepForward() => seek(state.position + const Duration(seconds: 10));
  void stepBackward() => seek(state.position - const Duration(seconds: 10));
  void volumeUp() => setVolume((state.volume + 5).clamp(0, 100));
  void volumeDown() => setVolume((state.volume - 5).clamp(0, 100));
}

final playerProvider = NotifierProvider<PlayerNotifier, AmphiPlayerState>(() {
  return PlayerNotifier();
});
