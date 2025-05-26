import 'package:flutter/material.dart';
import 'package:login_view/login.dart';
import 'package:zuzu/views_integration/user_root.dart';

class LoginIntegration extends StatelessWidget {
  const LoginIntegration({super.key});

  void handleLogin(BuildContext context, Key key) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => UserRoot(userKey: key)),
      (Route route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Login(onLogin: (Key key) => handleLogin(context, key));
  }
}
