import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shorts_view/bloc/video_player_events.dart';
import 'package:shorts_view/bloc/video_player_state.dart';
import 'package:video_player/video_player_controller.dart';
import 'package:video_player/video_player_platform.dart';

class VideoPlayerBloc extends Bloc<dynamic, VideoPlayerState> {
  VideoPlayerBloc({required String source, required bool preventMedia})
      : super(VideoPlayerState()) {
    _controller = VideoPlayerController();
    _controller.setDataSource(url: source);
    if (!preventMedia) {
      _controller.setAutoPlay();
    }
    _controller.initialize();
    _controller.addListener(() => add(_controller.value));

    on<VideoPlayerEvent>(_handlePlayerEvent);
    on<SeekToEvent>(_handleSeekTo);
    on<VideoPauseEvent>(_handlePause);
    on<PreventMediaUpdatedEvent>(_handleMediaPreventUpdated);
  }

  late final VideoPlayerController _controller;

  void _handlePlayerEvent(VideoPlayerEvent event, Emitter<VideoPlayerState> emit) {
    emit(state.copyWith(
      id: event.id,
      initialized: event.initialized,
      isPlaying: event.playing,
      seeking: event.seeking,
      loading: event.loading,
      duration: event.duration,
      position: event.position,
      aspectRatio: event.aspectRatio,
    ));
  }

  Future<void> _handleSeekTo(SeekToEvent event, Emitter<VideoPlayerState> emit) async {
    await _controller.seekTo(event.duration);
  }

  void _handlePause(VideoPauseEvent event, Emitter<VideoPlayerState> emit) async {
    event.pause ? await _controller.pause() : await _controller.play();
    emit(state.copyWith(isPaused: event.pause));
  }

  void _handleMediaPreventUpdated(PreventMediaUpdatedEvent event, Emitter<VideoPlayerState> emit) {
    event.prevent || state.isPaused ? _controller.pause() : _controller.play();
  }

  @override
  Future<void> close() async {
    _controller.dispose();
    return super.close();
  }
}
