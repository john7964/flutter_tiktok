class VideoEvent {}

class SeekToEvent extends VideoEvent {
  final Duration duration;

  SeekToEvent(this.duration);
}

class VideoPauseEvent extends VideoEvent {
  VideoPauseEvent({required this.pause});

  final bool pause;
}

class VideoDurationUpdatedEvent {
  VideoDurationUpdatedEvent(int value) : duration = Duration(milliseconds: value);

  final Duration duration;
}

class VideoPlayPositionUpdate {
  VideoPlayPositionUpdate(int value) : position = Duration(milliseconds: value);

  final Duration position;
}

class PreventMediaUpdatedEvent extends VideoEvent {
  PreventMediaUpdatedEvent({required this.prevent});

  final bool prevent;
}

class LoadingStateUpdatedEvent extends VideoEvent {
  final bool isLoading;

  LoadingStateUpdatedEvent(this.isLoading);
}

class PlayStateUpdatedEvent extends VideoEvent {
  final bool playing;

  PlayStateUpdatedEvent(this.playing);
}

class SeekCompleteEvent extends VideoEvent {}

class PlayerInitializedEvent extends VideoEvent {}

class PlayerAspectRatioUpdatedEvent extends VideoEvent {
  final double aspectRatio;

  PlayerAspectRatioUpdatedEvent(this.aspectRatio);
}

class ViewIdUpdatedEvent extends VideoEvent {
  ViewIdUpdatedEvent(this.viewId);

  final int viewId;
}
