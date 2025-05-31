import 'package:flutter/widgets.dart';

class ExpandedAlign extends StatelessWidget {
  const ExpandedAlign({
    super.key,
    this.flex = 1,
    this.alignment = Alignment.topCenter,
    required this.child,
  });

  final int flex;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: Align(alignment: alignment, child: child));
  }
}
