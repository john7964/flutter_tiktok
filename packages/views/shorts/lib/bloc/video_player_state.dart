class VideoPlayerState {
  const VideoPlayerState({
    this.id,
    this.initialized = false,
    this.isPlaying = false,
    this.isPaused = false,
    this.duration,
    this.position,
    this.aspectRatio,
    this.seeking = false,
    this.loading = false,
  });

  final int? id;
  final bool seeking;
  final bool initialized;
  final bool isPaused;
  final bool isPlaying;
  final bool loading;
  final Duration? duration;
  final Duration? position;
  final double? aspectRatio;

  VideoPlayerState copyWith({
    int? id,
    String? source,
    bool? initialized,
    bool? isPlaying,
    bool? isPaused,
    Duration? duration,
    Duration? position,
    bool? seeking,
    bool? loading,
    double? aspectRatio,
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
      id: id ?? this.id,
    );
  }
}
