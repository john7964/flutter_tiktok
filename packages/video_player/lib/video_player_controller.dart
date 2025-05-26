import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player_platform.dart';

class VideoPlayerController extends ValueNotifier<VideoPlayerEvent> {
  VideoPlayerController() : super(VideoPlayerEvent()) {
    Future<int?> create = VideoPlayerPlatform().create();
    platformMethod = create.then((id) => VideoPlayerMethod(id!));

    subscription = create.then((id) {
      final platformEvent = VideoPlayerControllerPlatformEvent(id!);
      return platformEvent.eventStream.listen((value) => this.value = value);
    });
  }

  late final Future<VideoPlayerMethod> platformMethod;
  late final Future<VideoPlayerControllerPlatformEvent> platformEvent;
  late final Future<StreamSubscription<VideoPlayerEvent>> subscription;

  Future<void> setDataSource({String? url}) async {
    await (await platformMethod).setDataSource(url: url);
  }

  Future<void> initialize() async {
    await subscription;
    await (await platformMethod).initialize();
  }

  Future<void> setAutoPlay([bool autoPlay = true]) async {
    await (await platformMethod).setAutoPlay(autoPlay);
  }

  Future<void> play() async {
    await (await platformMethod).start();
  }

  Future<void> pause() async {
    await (await platformMethod).pause();
  }

  Future<void> stop() async {
    await (await platformMethod).stop();
  }

  Future<void> seekTo(Duration position) async {
    await (await platformMethod).seekTo(position);
  }

  Future<void> setSpeed(double speed) async {
    await (await platformMethod).setSpeed(speed);
  }

  @override
  void dispose() {
    subscription.then((v) => v.cancel());
    platformMethod.then((_) => dispose());
    super.dispose();
  }
}
