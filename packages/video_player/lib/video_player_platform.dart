import 'package:flutter/services.dart';

class VideoPlayerPlatform {
  static MethodChannel methodChannel = MethodChannel("kimi.video.player");
  static VideoPlayerPlatform instance = VideoPlayerPlatform();

  Future<int?> create() async {
    return await methodChannel.invokeMethod<int>("create");
  }
}

const String tag = "VideoPlayerController";

class VideoPlayerMethod {
  final MethodChannel methodChannel;
  final int id;

  VideoPlayerMethod(this.id) : methodChannel = MethodChannel("method$tag#$id");

  Future<void> setDataSource({String? url}) async {
    await methodChannel.invokeMethod("setDataSource", {"url": url});
  }

  Future<void> initialize() async {
    await methodChannel.invokeMethod("initialize");
  }

  Future<void> setAutoPlay([bool autoPlay = true]) async {
    await methodChannel.invokeMethod("setAutoPlay", {"autoPlay": autoPlay});
  }

  Future<void> start() async {
    await methodChannel.invokeMethod("start");
  }

  Future<void> pause() async {
    await methodChannel.invokeMethod("pause");
  }

  Future<void> stop() async {
    await methodChannel.invokeMethod("stop");
  }

  Future<void> dispose() async {
    await methodChannel.invokeMethod("dispose");
  }

  Future<void> setSpeed(double speed) async {
    await methodChannel.invokeMethod("setSpeed", {"speed": speed});
  }

  Future<void> seekTo(Duration position) async {
    await methodChannel.invokeMethod("seekTo", {"position": position.inMilliseconds});
  }
}

class VideoPlayerControllerPlatformEvent {
  VideoPlayerControllerPlatformEvent(int id)
    : eventChannel = EventChannel("event$tag#$id", JSONMethodCodec()) {
    eventStream = eventChannel.receiveBroadcastStream().map((event) {
      print("event: $event");
      return VideoPlayerEvent(
        id: event["id"],
        initialized: event["initialized"],
        playing: event["playing"],
        loading: event["loading"],
        seeking: event["seeking"],
        speed: event["speed"] is int ? event["speed"].toDouble() : event["speed"],
        aspectRatio: event["aspectRatio"],
        duration: event["duration"] != null ? Duration(milliseconds: event["duration"]) : null,
        position: event["position"] != null ? Duration(milliseconds: event["position"]) : null,
      );
    });
  }

  late final Stream<VideoPlayerEvent> eventStream;
  final EventChannel eventChannel;
}

class VideoPlayerEvent {
  VideoPlayerEvent({
    this.id,
    this.initialized = false,
    this.playing = false,
    this.loading = false,
    this.seeking = false,
    this.speed = 1.0,
    this.aspectRatio,
    this.duration,
    this.position,
  });
  final int? id;
  final bool initialized;
  final bool playing;
  final bool loading;
  final bool seeking;
  final double speed;
  final double? aspectRatio;
  final Duration? duration;
  final Duration? position;
}
