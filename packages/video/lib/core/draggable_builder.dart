import 'package:flutter/gestures.dart';
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

  late final Map<Type, GestureRecognizerFactory> gestures = {
    LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
      () => LongPressGestureRecognizer(debugOwner: this, duration: Duration(milliseconds: 100)),
      (LongPressGestureRecognizer instance) {
        instance
          ..onLongPressStart = _handleLongPressStart
          ..onLongPressMoveUpdate = _handleLongPressUpdate
          ..onLongPressEnd = _handleLongPressEnd;
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
              ..onEnd = _handleDragEnd;
          },
        ),
  };

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
    return RawGestureDetector(
      key: _childKey,
      behavior: HitTestBehavior.opaque,
      gestures: gestures,
      child: widget.child,
    );
  }
}
