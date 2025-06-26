import 'dart:math';
import 'package:flutter/cupertino.dart';

class PositionedPopupRoute<T> extends PopupRoute<T> {
  PositionedPopupRoute({
    super.settings,
    super.requestFocus,
    super.filter,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
    required this.builder,
    required this.offset,
    required this.alignment,
  });

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  final Alignment alignment;
  final Offset offset;

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);

  // @override
  // Duration get reverseTransitionDuration => Duration.zero;

  final WidgetBuilder builder;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final TweenSequence<double> scaleTween = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 0.7),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 0.3),
    ]);

    final CurvedAnimation tweenCurve = CurvedAnimation(parent: animation, curve: Curves.linear);
    final double scale = tweenCurve.drive(scaleTween).value;

    return PositionedAlign(
      offset: offset,
      alignment: alignment,
      child: Opacity(
        opacity: min(1.0, scale),
        child: Transform.scale(alignment: alignment, scale: scale, child: child),
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }
}

class PositionedAlign extends CustomSingleChildLayout {
  PositionedAlign({
    super.key,
    required Alignment alignment,
    required Offset offset,
    required super.child,
  }) : super(delegate: PositionedAlignDelegate(alignment: alignment, offset: offset));
}

class PositionedAlignDelegate extends SingleChildLayoutDelegate {
  final Alignment alignment;
  final Offset offset;

  PositionedAlignDelegate({super.relayout, required this.alignment, required this.offset});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    Alignment targetAlignment = alignment;
    Offset targetOffset = targetAlignment.alongSize(childSize);
    Offset result = offset - targetOffset;

    final Rectangle rect = Rectangle(result.dx, result.dy, childSize.width, childSize.height);

    if (rect.topLeft.x < 0) {
      targetAlignment = Alignment(targetAlignment.x - 1.0, targetAlignment.y);
    }
    if (rect.topLeft.y < 0) {
      targetAlignment = Alignment(targetAlignment.x, targetAlignment.y - 2.0);
    }

    if (rect.bottomRight.x > size.width) {
      targetAlignment = Alignment(targetAlignment.x + 1.0, targetAlignment.y);
    }
    if (rect.bottomRight.y > size.height) {
      targetAlignment = Alignment(targetAlignment.x, targetAlignment.y + 2.0);
    }

    targetOffset = targetAlignment.alongSize(childSize);
    return offset - targetOffset;
  }

  @override
  bool shouldRelayout(covariant PositionedAlignDelegate oldDelegate) {
    return oldDelegate.alignment != alignment || oldDelegate.offset != offset;
  }
}
