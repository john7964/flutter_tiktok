import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widget_state/authed_user.dart';

class AuthedUserBloc extends Bloc<AuthedUserEvent, AuthedUserState> {
  AuthedUserBloc(Key user) : super(AuthedUserState(user));
}
