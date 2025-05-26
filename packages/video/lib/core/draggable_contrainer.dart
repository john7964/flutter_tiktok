import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

class DraggableBox extends StatefulWidget {
  const DraggableBox({
    super.key,
    required this.alignment,
    required this.child,
    required this.controller,
  });

  final Alignment alignment;
  final Widget child;
  final AnimationController controller;

  @override
  State<DraggableBox> createState() => _DraggableBoxState();
}

class _DraggableBoxState extends State<DraggableBox> {
  final GlobalKey _childKey = GlobalKey();

  late final Map<Type, GestureRecognizerFactory> gestures = {
    VerticalDragGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(debugOwner: this),
          (VerticalDragGestureRecognizer instance) {
            instance
              ..onlyAcceptDragOnThreshold = true
              ..onStart = _handleDragStart
              ..onUpdate = _handleDragUpdate
              ..onEnd = (details) => _handleDragEnd(details, Axis.vertical);
          },
        ),
    HorizontalDragGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(debugOwner: this),
          (HorizontalDragGestureRecognizer instance) {
            instance
              ..onlyAcceptDragOnThreshold = false
              ..onStart = _handleDragStart
              ..onUpdate = _handleDragUpdate
              ..onEnd = (details) => _handleDragEnd(details, Axis.horizontal);
          },
        ),
  };

  double get _childHeight {
    final RenderBox renderBox = _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  bool get _dismissUnderway => widget.controller.status == AnimationStatus.reverse;

  Set<WidgetState> dragHandleStates = <WidgetState>{};

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      dragHandleStates.add(WidgetState.dragged);
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dismissUnderway) {
      return;
    }
    widget.controller.value -= details.primaryDelta! / _childHeight;
  }

  void _handleDragEnd(DragEndDetails details, Axis axis) {
    if (_dismissUnderway) {
      return;
    }
    setState(() {
      dragHandleStates.remove(WidgetState.dragged);
    });

    double pixelsPerSecond =
        axis == Axis.vertical
            ? details.velocity.pixelsPerSecond.dy
            : details.velocity.pixelsPerSecond.dx;

    if (pixelsPerSecond > _minFlingVelocity) {
      final double flingVelocity = -pixelsPerSecond / _childHeight;
      if (widget.controller.value > 0.0) {
        widget.controller.fling(velocity: flingVelocity);
      }
    } else if (widget.controller.value < _closeProgressThreshold) {
      if (widget.controller.value > 0.0) {
        widget.controller.fling(velocity: -1.0);
      }
    } else {
      widget.controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      child: PopScope(
        canPop: false,
        child: RawGestureDetector(
          gestures: gestures,
          child: KeyedSubtree(key: _childKey, child: widget.child),
        ),
      ),
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: widget.alignment,
            heightFactor: widget.controller.value,
            child: child,
          ),
        );
      },
    );
  }
}
