import 'package:flutter/material.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class MeView extends StatelessWidget {
  const MeView({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasScaffold = context.findAncestorStateOfType<ScaffoldState>() != null;
    Widget child = Center(child: Text("me"));
    if (!hasScaffold) {
      child = Scaffold(body: child);
    }
    return child;
  }
}
