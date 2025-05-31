class VideoEvent {}

class VideoPauseEvent extends VideoEvent {
  VideoPauseEvent({required this.pause});

  final bool pause;
}

class PreventMediaUpdatedEvent extends VideoEvent {
  PreventMediaUpdatedEvent({required this.prevent});

  final bool prevent;
}

class IndicatorDraggingEvent extends VideoEvent {
  IndicatorDraggingEvent({required this.offsetRatio});

  final double offsetRatio;
}

class PlayStateUpdatedEvent extends VideoEvent {
  final bool playing;

  PlayStateUpdatedEvent(this.playing);
}