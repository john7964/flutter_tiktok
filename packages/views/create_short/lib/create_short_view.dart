import 'package:flutter/material.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class CreateShortView extends StatelessWidget {
  const CreateShortView({super.key});

  static Route route() {
    return ModalBottomSheetRoute(
      builder: (context) => CreateShortView(),
      isScrollControlled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasScaffold = context.findAncestorStateOfType<ScaffoldState>() != null;
    Widget child = Center(child: Text("Create"));
    if (!hasScaffold) {
      child = Scaffold(body: child);
    }
    return child;
  }
}
