import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widget_state/splash.dart';

class SplashBloc extends Bloc<ToggleSplashEvent, SplashState> {
  SplashBloc() : super(SplashState(showSplash: true)) {
    on<ToggleSplashEvent>(_handle);
  }

  Future<void> _handle(ToggleSplashEvent event, Emitter<SplashState> emit) async {
    emit(SplashState(showSplash: false));
  }
}
