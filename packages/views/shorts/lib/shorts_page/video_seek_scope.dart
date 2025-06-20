import 'package:flutter/material.dart';

import '../core/draggable_builder.dart';

class DraggableIndicator extends StatefulWidget {
  const DraggableIndicator({super.key, required this.onChange});

  final ValueSetter<double> onChange;

  @override
  State<DraggableIndicator> createState() => _DraggableIndicatorState();
}

class _DraggableIndicatorState extends State<DraggableIndicator> {
  late double dragRatio = 0.0;

  void _handleDragStart() {
    dragRatio = 0.0;
    widget.onChange(double.negativeInfinity);
  }

  void _handleDragUpdate(double offsetRatio) {
    dragRatio += offsetRatio;
    widget.onChange(dragRatio);
  }

  void _handleDragEnd() async {
    widget.onChange(double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableBar(
      hitTestBehavior: HitTestBehavior.translucent,
      onDragStart: _handleDragStart,
      onDragUpdate: _handleDragUpdate,
      onDragEnd: _handleDragEnd,
      child: Container(height: 130),
    );
  }
}
