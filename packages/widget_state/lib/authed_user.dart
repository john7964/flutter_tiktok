import 'package:flutter/cupertino.dart';

class AuthedUserState {
  final Key user;

  AuthedUserState(this.user);
}

sealed class AuthedUserEvent {}
