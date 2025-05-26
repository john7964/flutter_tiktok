class VideoEvent {}

class SeekToEvent extends VideoEvent {
  final Duration duration;

  SeekToEvent(this.duration);
}

class VideoPauseEvent extends VideoEvent {
  VideoPauseEvent({required this.pause});

  final bool pause;
}
