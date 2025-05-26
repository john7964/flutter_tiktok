import 'package:flutter/material.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class MessageView extends StatelessWidget {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasScaffold = context.findAncestorStateOfType<ScaffoldState>() != null;
    Widget child = Center(child: Text("MessageView"));
    if (!hasScaffold) {
      child = Scaffold(body: child);
    }
    return child;
  }
}
