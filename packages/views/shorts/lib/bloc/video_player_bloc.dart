import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shorts_view/bloc/video_player_events.dart';
import 'package:shorts_view/bloc/video_player_state.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerBloc extends Bloc<dynamic, VideoPlayerState> {
  VideoPlayerBloc({required String source})
      : super(
          VideoPlayerState(
            controller: VideoPlayerController.network(source),
          ),
        ) {
    _initializeFuture = _controller.initialize().then((value) async {
      await _controller.setLooping(true);
    });

    _controller.addListener(() => add(_controller.value));

    on<VideoPlayerValue>(_handlePlayerEvent);
    on<IndicatorDraggingEvent>(_handleSeekTo);
    on<VideoPauseEvent>(_handlePause);
    on<PreventMediaUpdatedEvent>(_handleMediaPreventUpdated);
  }

  VideoPlayerController get _controller => state.controller;
  late Future<void> _initializeFuture;

  void _handlePlayerEvent(VideoPlayerValue event, Emitter<VideoPlayerState> emit) {
    emit(state.copyWith(
      initialized: event.isInitialized,
      isPlaying: event.isPlaying,
      duration: event.duration,
      position: event.position,
      aspectRatio: event.aspectRatio,
    ));
  }

  Future<void> _handleSeekTo(IndicatorDraggingEvent event, Emitter<VideoPlayerState> emit) async {
    if ((state.duration ?? Duration.zero) == Duration.zero) {
      return;
    }
    switch (event.offsetRatio) {
      case double.negativeInfinity:
        emit(state.copyWith(
          isDragging: true,
          dragStartPosition: state.position,
          dragPosition: state.position,
        ));
        break;
      case double.infinity:
        if (!state.isDragging) {
          return;
        }
        final Duration dragPosition = state.dragPosition;
        emit(state.copyWith(
          isDragging: false,
          dragPosition: Duration.zero,
          dragStartPosition: Duration.zero,
          isPaused: false,
        ));
        await _controller.seekTo(dragPosition);
        if (!state.preventMedia) {
          _controller.play();
        }
        break;
      default:
        if (!state.isDragging) {
          emit(state.copyWith(isDragging: true, dragStartPosition: state.position));
        }
        final Duration position = state.duration! * event.offsetRatio + state.dragStartPosition;
        emit(state.copyWith(isDragging: true, dragPosition: position));
    }
  }

  void _handlePause(VideoPauseEvent event, Emitter<VideoPlayerState> emit) async {
    emit(state.copyWith(isPaused: event.pause));
    _initializeFuture.then((value) {
      event.pause || state.preventMedia ? _controller.pause() : _controller.play();
    });
  }

  void _handleMediaPreventUpdated(PreventMediaUpdatedEvent event, Emitter<VideoPlayerState> emit) {
    emit(state.copyWith(preventMedia: event.prevent));
    _initializeFuture.then((value) {
      event.prevent || state.isPaused ? _controller.pause() : _controller.play();
    });
  }

  @override
  Future<void> close() async {
    _controller.pause().then((value) {
      _controller.dispose();
    });
    return super.close();
  }
}
