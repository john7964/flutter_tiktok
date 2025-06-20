import 'package:bloc/bloc.dart';
import 'package:shorts_view/bloc/video_player_bloc.dart';

class ShortsEvent {}

class UpdatedPlayingIndexEvent extends ShortsEvent {
  final int index;

  UpdatedPlayingIndexEvent(this.index);
}

class ShortsState {
  ShortsState({required this.players, this.loading = false, this.lastPlayingIndex = 0});

  final bool loading;
  final List<ShortBloc> players;
  final int lastPlayingIndex;

  ShortsState copyWith({bool? loading, List<ShortBloc>? players, int? lastPlayingIndex}) {
    return ShortsState(
      players: players ?? this.players,
      loading: loading ?? this.loading,
      lastPlayingIndex: lastPlayingIndex ?? this.lastPlayingIndex,
    );
  }
}

class ShortPlayersBloc extends Bloc<ShortsEvent, ShortsState> {
  ShortPlayersBloc({required List<String> sources})
      : super(
          ShortsState(players: sources.map((source) => ShortBloc(source: source)).toList()),
        ) {
    on<UpdatedPlayingIndexEvent>(handlePlayingIndexChanged);
    // for (int index = 0; index < state.players.length; index++) {
    //   state.players[index].verify.addListener(
    //     () => handlePlayerVerifyChange(
    //       index,
    //       state.players[index].verify.value,
    //     ),
    //   );
    // }
  }

  void handlePlayingIndexChanged(UpdatedPlayingIndexEvent event, Emitter<ShortsState> emitter) {
    emitter(state.copyWith(lastPlayingIndex: event.index));
  }

  @override
  Future<void> close() {
    for (var bloc in state.players) {
      bloc.close();
    }
    return super.close();
  }
}
