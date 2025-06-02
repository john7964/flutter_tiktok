import 'package:flutter/widgets.dart';

class PreventScroll extends StatelessWidget {
  const PreventScroll({
    super.key,
    this.child,
    this.prevent = true,
    this.onTap,
    this.hitTestBehavior,
  });

  final Widget? child;
  final bool prevent;
  final VoidCallback? onTap;
  final HitTestBehavior? hitTestBehavior;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: hitTestBehavior,
      onVerticalDragStart: prevent ? (event) {} : null,
      onHorizontalDragStart: prevent ? (event) {} : null,
      onTap: onTap,
      child: child,
    );
  }
}
