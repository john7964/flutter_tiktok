import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.onLogin});

  final void Function(Key key) onLogin;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: TextButton(onPressed: () => widget.onLogin(Key("")), child: Text("登录"))),
    );
  }
}
