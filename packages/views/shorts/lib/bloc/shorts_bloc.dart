import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shorts_view/bloc/video_player_bloc.dart';
import 'package:ui_kit/media_certificate/media_certificate.dart';

class PlayListEvent {}

class UpdatedPlayingIndexEvent extends PlayListEvent {
  final int? index;

  UpdatedPlayingIndexEvent(this.index);
}

class UpdateCertificationConsumer extends PlayListEvent {
  UpdateCertificationConsumer({required this.consumer});

  final MediaCertificationConsumer consumer;
}

class PlayListState {
  PlayListState({required this.players, this.loading = false, this.playingIndex});

  final bool loading;
  final List<VideoPlayerBloc> players;
  final int? playingIndex;

  VideoPlayerBloc? get currentPlayer => playingIndex == null ? null : players[playingIndex!];

  PlayListState copyWith({bool? loading, List<VideoPlayerBloc>? players, int? lastPlayingIndex}) {
    return PlayListState(
      players: players ?? this.players,
      loading: loading ?? this.loading,
      playingIndex: lastPlayingIndex ?? playingIndex,
    );
  }
}

class PlayListBloc extends Bloc<PlayListEvent, PlayListState> {
  PlayListBloc({required List<String> sources})
      : super(
          PlayListState(players: sources.map((source) => VideoPlayerBloc(source: source)).toList()),
        ) {
    on<UpdateCertificationConsumer>(_handleAddMediaCertificationConsumerEvent);
    on<UpdatedPlayingIndexEvent>(handlePlayingIndexChanged);
    verify.addListener(_handleCurrentPlayStateUpdate);
    add(UpdatedPlayingIndexEvent(0));
  }

  final MediaCertificationVerify verify = MediaCertificationVerify();

  StreamSubscription<VideoPlayerState>? currentPlayerListener;

  void _handleCurrentPlayStateUpdate([VideoPlayerState? playerState]) {
    if (state.currentPlayer == null) {
      return;
    }
    final VideoPlayerState playerState = state.currentPlayer!.state;
    if (verify.value && !playerState.isPaused) {
      if (!playerState.isPlaying) {
        playerState.controller.play();
        playerState.controller.setLooping(true);
      }
    } else {
      if (playerState.isPlaying) {
        playerState.controller.pause();
      }
    }
  }

  void handlePlayingIndexChanged(
    UpdatedPlayingIndexEvent event,
    Emitter<PlayListState> emitter,
  ) async {
    if (event.index == state.playingIndex) {
      return;
    }

    await currentPlayerListener?.cancel();
    currentPlayerListener = null;

    if (state.currentPlayer != null) {
      state.currentPlayer!.state.controller.pause();
    }

    emitter(state.copyWith(lastPlayingIndex: event.index));
    if (state.currentPlayer != null) {
      _handleCurrentPlayStateUpdate();
      currentPlayerListener = state.currentPlayer!.stream.listen(_handleCurrentPlayStateUpdate);
    }
    print(state.playingIndex);
  }

  void _handleAddMediaCertificationConsumerEvent(
    UpdateCertificationConsumer event,
    Emitter<PlayListState> emit,
  ) {
    verify.addConsumer(event.consumer);
  }

  @override
  Future<void> close() {
    for (var bloc in state.players) {
      bloc.close();
    }
    return super.close();
  }
}
