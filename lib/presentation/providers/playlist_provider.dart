import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PlaylistItem {
  final String path;
  final String title;
  final bool isVideo;
  final bool isNetwork;

  PlaylistItem({
    required this.path,
    required this.title,
    required this.isVideo,
    this.isNetwork = false,
  });

  factory PlaylistItem.fromPath(String path) {
    if (path.startsWith('http') || path.startsWith('rtsp')) {
      return PlaylistItem(
        path: path,
        title: path.split('/').last.isEmpty ? path : path.split('/').last,
        isVideo: true, // Assume video for streams, or refine later
        isNetwork: true,
      );
    }
    
    final file = File(path);
    final fileName = file.path.split(Platform.pathSeparator).last;
    final extension = fileName.split('.').last.toLowerCase();
    final isVideo = ['mp4', 'mkv', 'avi', 'mov', 'webm'].contains(extension);
    
    return PlaylistItem(
      path: path,
      title: fileName,
      isVideo: isVideo,
      isNetwork: false,
    );
  }
}

class PlaylistState {
  final List<PlaylistItem> items;
  final int currentIndex;

  PlaylistState({
    required this.items,
    this.currentIndex = -1,
  });

  PlaylistState copyWith({
    List<PlaylistItem>? items,
    int? currentIndex,
  }) {
    return PlaylistState(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class PlaylistNotifier extends Notifier<PlaylistState> {
  static const _keyPaths = 'playlist_paths';
  static const _keyIndex = 'playlist_index';

  @override
  PlaylistState build() {
    _load();
    return PlaylistState(items: []);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_keyPaths) ?? [];
    final index = prefs.getInt(_keyIndex) ?? -1;
    
    if (paths.isNotEmpty) {
      final items = paths.map((p) => PlaylistItem.fromPath(p)).toList();
      state = PlaylistState(items: items, currentIndex: index);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyPaths, state.items.map((i) => i.path).toList());
    await prefs.setInt(_keyIndex, state.currentIndex);
  }

  void addItems(List<String> paths) {
    final newItems = paths.map((p) => PlaylistItem.fromPath(p)).toList();
    state = state.copyWith(items: [...state.items, ...newItems]);
    
    if (state.currentIndex == -1 && state.items.isNotEmpty) {
      setCurrentIndex(state.items.length - newItems.length);
    } else {
      _save();
    }
  }

  void addUrl(String url) {
    if (url.isEmpty) return;
    final item = PlaylistItem.fromPath(url);
    state = state.copyWith(items: [...state.items, item]);
    if (state.currentIndex == -1) {
      setCurrentIndex(state.items.length - 1);
    } else {
      _save();
    }
  }

  void removeItem(int index) {
    final newList = [...state.items];
    newList.removeAt(index);
    
    int nextIndex = state.currentIndex;
    if (index == state.currentIndex) {
      nextIndex = newList.isEmpty ? -1 : (index % newList.length);
    } else if (index < state.currentIndex) {
      nextIndex--;
    }

    state = state.copyWith(items: newList, currentIndex: nextIndex);
    _save();
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < state.items.length) {
      state = state.copyWith(currentIndex: index);
      _save();
    }
  }

  void next() {
    if (state.items.isEmpty) return;
    setCurrentIndex((state.currentIndex + 1) % state.items.length);
  }

  void previous() {
    if (state.items.isEmpty) return;
    setCurrentIndex((state.currentIndex - 1 + state.items.length) % state.items.length);
  }
  
  void clear() {
    state = PlaylistState(items: [], currentIndex: -1);
    _save();
  }
}

final playlistProvider = NotifierProvider<PlaylistNotifier, PlaylistState>(() {
  return PlaylistNotifier();
});
