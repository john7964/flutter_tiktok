import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreventMedia extends InheritedWidget {
  const PreventMedia({super.key, required this.prevent, required super.child});
  final bool prevent;

  @override
  bool updateShouldNotify(covariant PreventMedia oldWidget) => prevent != oldWidget.prevent;

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PreventMedia>()?.prevent ?? false;
  }
}
