import 'package:flutter/foundation.dart';

enum AuthenticationStatus { loading, authenticated, unAuthenticated }

class AuthState {
  final AuthenticationStatus status;
  final Key? authentication;

  AuthState({required this.status, this.authentication});
}

sealed class AuthEvent {}
