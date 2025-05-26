import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shorts/bloc/video_player_events.dart';
import 'package:shorts/bloc/video_player_state.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerBloc extends Bloc<dynamic, VideoPlayerState> {
  VideoPlayerBloc(String source)
    : controller = VideoPlayerController.network(
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      ),
      super(VideoPlayerState(source: source)) {
    on<SeekToEvent>(handleSeekTo);
    on<VideoPlayerValue>(handleVideoPlayerValueUpdate);
    on<VideoPauseEvent>(handlePause);
    controller.setLooping(true);
    controller.play();
    controller.initialize();
    controller.addListener(() => add(controller.value));
  }

  late VideoPlayerController controller;

  Future<void> handleSeekTo(SeekToEvent event, Emitter<VideoPlayerState> emit) async {
    controller.play();
    await controller.seekTo.call(event.duration);
    emit(state.copyWith(isPaused: false, seeking: true));
  }

  void handleVideoPlayerValueUpdate(VideoPlayerValue event, Emitter<VideoPlayerState> emit) {
    int max = 0;
    for (var el in event.buffered) {
      max = el.end.inMilliseconds;
    }
    late bool loading = (max <= event.position.inMilliseconds);

    late bool seeking = state.seeking && !loading ? false : state.seeking;
    emit(
      event.isInitialized
          ? state.copyWith(
            initialized: event.isInitialized,
            isPlaying: event.isPlaying,
            duration: event.duration,
            position: event.position,
            seeking: seeking,
            loading: loading,
          )
          : VideoPlayerState(source: state.source),
    );
  }

  void handlePause(VideoPauseEvent event, Emitter<VideoPlayerState> emit) async {
    event.pause ? await controller.pause() : await controller.play();
    emit(state.copyWith(isPaused: event.pause));
  }
}
