import 'package:flutter/cupertino.dart';

mixin AppBarManager<T extends StatefulWidget> on State<T> {
  @mustCallSuper
  void changeAppBar({bool? top, bool? bottom}) {
    AppBarManager.maybeOf(context)?.changeAppBar(top: top, bottom: bottom);
  }

  static AppBarManager? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<AppBarManager>();
  }
}
