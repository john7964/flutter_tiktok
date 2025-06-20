import 'package:flutter/material.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class MallView extends StatelessWidget {
  const MallView({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasScaffold = context.findAncestorStateOfType<ScaffoldState>() != null;
    Widget child = Center(child: Text("mall"));
    if (!hasScaffold) {
      child = Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
        child: Scaffold(body: child),
      );
    }
    return child;
  }
}
