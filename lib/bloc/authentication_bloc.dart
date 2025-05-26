import 'package:bloc/bloc.dart';
import 'package:widget_state/authentication.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState(status: AuthenticationStatus.loading));
}
