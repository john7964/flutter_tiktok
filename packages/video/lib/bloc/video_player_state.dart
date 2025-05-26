class VideoPlayerState {
  const VideoPlayerState({
    required this.source,
    this.initialized = false,
    this.isPlaying = false,
    this.isPaused = false,
    this.duration,
    this.position = const Duration(milliseconds: 0),
    this.seeking = false,
    this.loading = false,
  });

  final bool seeking;
  final bool initialized;
  final String source;
  final bool isPaused;
  final bool isPlaying;
  final bool loading;
  final Duration? duration;
  final Duration position;

  VideoPlayerState copyWith({
    String? source,
    bool? initialized,
    bool? isPlaying,
    bool? isPaused,
    Duration? duration,
    Duration? position,
    bool? seeking,
    bool? loading,
  }) {
    return VideoPlayerState(
      source: source ?? this.source,
      initialized: initialized ?? this.initialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      seeking: seeking ?? seeking ?? this.seeking,
      loading: loading ?? this.loading,
    );
  }
}
