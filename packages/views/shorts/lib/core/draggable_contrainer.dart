import 'package:flutter/material.dart';

const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

class DraggableBox extends StatefulWidget {
  const DraggableBox({
    super.key,
    required this.child,
    required this.controller,
  });

  final DraggableScrollableController controller;
  final Widget child;

  @override
  State<DraggableBox> createState() => _DraggableBoxState();
}

class _DraggableBoxState extends State<DraggableBox> with SingleTickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey();
  late final AnimationController controller;

  double get _childHeight {
    final RenderBox? renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 0.0;
  }

  bool get _dismissUnderway => controller.status == AnimationStatus.reverse;

  Set<WidgetState> dragHandleStates = <WidgetState>{};

  void _handleDragStart(DragStartDetails details) {
    controller.value = widget.controller.size;
    setState(() {
      dragHandleStates.add(WidgetState.dragged);
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    controller.value -= details.primaryDelta! / _childHeight;
  }

  void _handleDragEnd(DragEndDetails details, Axis axis) {
    setState(() {
      dragHandleStates.remove(WidgetState.dragged);
    });

    double pixelsPerSecond = axis == Axis.vertical
        ? details.velocity.pixelsPerSecond.dy
        : details.velocity.pixelsPerSecond.dx;

    if (pixelsPerSecond > _minFlingVelocity) {
      final double flingVelocity = -pixelsPerSecond;
      if (controller.value > 0.0) {
        // controller.fling(velocity: flingVelocity);
        controller.reverse();
      }
    } else if (controller.value < _closeProgressThreshold) {
      if (controller.value > 0.0) {
        controller.fling(velocity: -20.0);
      }
    } else {
      controller.forward();
    }
  }

  void handleAnimationChanged() {
    print("jump: ${controller.value} ${DateTime.now().millisecondsSinceEpoch}");
    if(widget.controller.size != 0.0){
      widget.controller.jumpTo(controller.value);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 64));
    controller.addListener(handleAnimationChanged);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: (details) => _handleDragEnd(details, Axis.horizontal),
        onVerticalDragStart: _handleDragStart,
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: (details) => _handleDragEnd(details, Axis.vertical),
        child: KeyedSubtree(key: _childKey, child: widget.child),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
