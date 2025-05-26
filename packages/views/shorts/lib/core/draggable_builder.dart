import 'package:flutter/widgets.dart';

class DraggableBar extends StatefulWidget {
  const DraggableBar({
    super.key,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  final VoidCallback onDragStart;
  final ValueSetter<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final Widget child;

  @override
  State<DraggableBar> createState() => _DraggableBarState();
}

class _DraggableBarState extends State<DraggableBar> {
  final GlobalKey _childKey = GlobalKey();

  double get _childWidth {
    final RenderBox renderBox = _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.width;
  }

  double previousDelta = 0;

  void _handleLongPressStart(LongPressStartDetails details) {
    widget.onDragStart();
    previousDelta = 0;
  }

  void _handleLongPressUpdate(LongPressMoveUpdateDetails details) {
    double delta = details.offsetFromOrigin.dx;
    widget.onDragUpdate((delta - previousDelta) / _childWidth);
    previousDelta = delta;
  }

  void _handleLongPressEnd(LongPressEndDetails details) => widget.onDragEnd();

  void _handleDragStart(DragStartDetails details) {
    widget.onDragStart();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    widget.onDragUpdate(details.primaryDelta! / _childWidth);
  }

  void _handleDragEnd(DragEndDetails details) => widget.onDragEnd();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _childKey,
      behavior: HitTestBehavior.opaque,
      onLongPressStart: _handleLongPressStart,
      onLongPressMoveUpdate: _handleLongPressUpdate,
      onLongPressEnd: _handleLongPressEnd,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: widget.child,
    );
  }
}
