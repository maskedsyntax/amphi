import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class PlaylistItem {
  final String path;
  final String title;
  final bool isVideo;

  PlaylistItem({
    required this.path,
    required this.title,
    required this.isVideo,
  });

  factory PlaylistItem.fromPath(String path) {
    final file = File(path);
    final fileName = file.path.split(Platform.pathSeparator).last;
    final extension = fileName.split('.').last.toLowerCase();
    final isVideo = ['mp4', 'mkv', 'avi', 'mov'].contains(extension);
    
    return PlaylistItem(
      path: path,
      title: fileName,
      isVideo: isVideo,
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
  @override
  PlaylistState build() {
    return PlaylistState(items: []);
  }

  void addItems(List<String> paths) {
    final newItems = paths.map((p) => PlaylistItem.fromPath(p)).toList();
    state = state.copyWith(items: [...state.items, ...newItems]);
    
    // If nothing is playing, play the first new item
    if (state.currentIndex == -1 && state.items.isNotEmpty) {
      setCurrentIndex(state.items.length - newItems.length);
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
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < state.items.length) {
      state = state.copyWith(currentIndex: index);
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
  }
}

final playlistProvider = NotifierProvider<PlaylistNotifier, PlaylistState>(() {
  return PlaylistNotifier();
});
