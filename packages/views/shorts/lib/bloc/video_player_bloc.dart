import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ui_kit/media_certificate/media_certificate.dart';
import 'package:video_player/video_player.dart';

class ShortBloc extends Bloc<dynamic, VideoPlayerState> {
  ShortBloc({required String source})
      :super(
          VideoPlayerState(
            controller:  VideoPlayerController.network(source),
          ),
        ) {
    _controller.addListener(handleControllerChanged);
    on<VideoPlayerValue>(_handlePlayerEvent);
    on<IndicatorDraggingEvent>(_handleSeekTo);
    on<VideoPauseEvent>(_handlePause);
    on<UpdateCertificationConsumer>(_handleMediaPreventUpdated);
    on<bool>(_handleVerifyChanged);

    _controller.initialize();
    handleControllerChanged();

    verify.addListener(() => add(verify.value));
  }

  VideoPlayerController get _controller => state.controller;
  final MediaCertificationVerify verify = MediaCertificationVerify();

  void handleControllerChanged() => add(_controller.value);

  void _handleVerifyChanged(bool verify, Emitter<VideoPlayerState> emit) {
    emit(state.copyWith(preventMedia: !verify));
    state.isPaused || state.preventMedia ? _controller.pause() : _controller.play();
  }

  void _handlePlayerEvent(VideoPlayerValue event, Emitter<VideoPlayerState> emit) {
    if (event.isInitialized && !state.initialized) {
      _controller.setLooping(true);
      if (state.preventMedia || state.isPaused) {
        _controller.pause();
      } else {
        _controller.play();
      }
    }
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
    state.isPaused || state.preventMedia ? _controller.pause() : _controller.play();
  }

  void _handleMediaPreventUpdated(
      UpdateCertificationConsumer event, Emitter<VideoPlayerState> emit) {
    verify.addConsumer(event.consumer);
  }

  @override
  Future<void> close() async {
    await _controller.pause();
    await _controller.dispose();
    return super.close();
  }
}

class VideoEvent {}

class VideoPauseEvent extends VideoEvent {
  VideoPauseEvent({required this.pause});

  final bool pause;
}

class UpdateCertificationConsumer extends VideoEvent {
  UpdateCertificationConsumer({required this.consumer});

  final MediaCertificationConsumer consumer;
}

class IndicatorDraggingEvent extends VideoEvent {
  IndicatorDraggingEvent({required this.offsetRatio});

  final double offsetRatio;
}

class PlayStateUpdatedEvent extends VideoEvent {
  final bool playing;

  PlayStateUpdatedEvent(this.playing);
}

class VideoPlayerState {
  const VideoPlayerState({
    this.preventMedia = true,
    this.initialized = false,
    this.isPlaying = false,
    this.isPaused = false,
    this.duration,
    this.position,
    this.aspectRatio,
    this.seeking = false,
    this.loading = false,
    this.dragPosition = Duration.zero,
    this.dragStartPosition = Duration.zero,
    required this.controller,
    this.isDragging = false,
  });

  final bool seeking;
  final bool initialized;
  final bool isPaused;
  final bool isPlaying;
  final bool loading;
  final Duration? duration;
  final Duration? position;
  final double? aspectRatio;
  final VideoPlayerController controller;
  final Duration dragPosition;
  final bool isDragging;
  final Duration dragStartPosition;
  final bool preventMedia;

  VideoPlayerState copyWith({
    int? id,
    String? source,
    bool? initialized,
    bool? isPlaying,
    bool? isPaused,
    Duration? duration,
    Duration? position,
    Duration? dragPosition,
    bool? seeking,
    bool? loading,
    double? aspectRatio,
    bool? isDragging,
    Duration? dragStartPosition,
    bool? preventMedia,
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
      controller: controller,
      preventMedia: preventMedia ?? this.preventMedia,
      dragPosition: dragPosition ?? this.dragPosition,
      isDragging: isDragging ?? this.isDragging,
      dragStartPosition: dragStartPosition ?? this.dragStartPosition,
    );
  }
}
