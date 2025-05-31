import 'package:video_player/video_player.dart';

class VideoPlayerState {
  const VideoPlayerState({
    this.preventMedia = true,
    this.initialized = false,
    this.isPlaying = false,
    this.isPaused = false,
    this.duration,
    this.position,
    this.aspectRatio,
    this.seeking = false,
    this.loading = false,
    this.dragPosition = Duration.zero,
    this.dragStartPosition = Duration.zero,
    required this.controller,
    this.isDragging = false,
  });

  final bool seeking;
  final bool initialized;
  final bool isPaused;
  final bool isPlaying;
  final bool loading;
  final Duration? duration;
  final Duration? position;
  final double? aspectRatio;
  final VideoPlayerController controller;
  final Duration dragPosition;
  final bool isDragging;
  final Duration dragStartPosition;
  final bool preventMedia;

  VideoPlayerState copyWith({
    int? id,
    String? source,
    bool? initialized,
    bool? isPlaying,
    bool? isPaused,
    Duration? duration,
    Duration? position,
    Duration? dragPosition,
    bool? seeking,
    bool? loading,
    double? aspectRatio,
    bool? isDragging,
    Duration? dragStartPosition,
    bool? preventMedia,
  }) {
    return VideoPlayerState(
        initialized: initialized ?? this.initialized,
        isPlaying: isPlaying ?? this.isPlaying,
        isPaused: isPaused ?? this.isPaused,
        duration: duration ?? this.duration,
        position: position ?? this.position,
        seeking: seeking ?? seeking ?? this.seeking,
        loading: loading ?? this.loading,
        aspectRatio: aspectRatio ?? this.aspectRatio,
        controller: controller,
        preventMedia: preventMedia ?? this.preventMedia,
        dragPosition: dragPosition ?? this.dragPosition,
        isDragging: isDragging ?? this.isDragging,
        dragStartPosition: dragStartPosition ?? this.dragStartPosition);
  }
}
