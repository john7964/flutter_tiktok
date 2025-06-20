import 'package:flutter/material.dart';
import 'package:shorts_view/comments/video_comment.dart';

import '../core/draggable_contrainer.dart';

const Duration _duration = Duration(milliseconds: 120);

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
    required this.controller,
    required this.height,
    required this.expandedHeight,
  });

  final DraggableScrollableController controller;
  final double height;
  final double expandedHeight;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> with SingleTickerProviderStateMixin {
  late final AnimationController expandController = AnimationController(
    vsync: this,
    duration: _duration,
  );

  @override
  Widget build(BuildContext context) {
    final Widget sheet = ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      child: VideoCommentsList(expandAnimation: expandController),
    );

    return AnimatedBuilder(
      animation: expandController,
      builder: (context, child) {
        final double progress = expandController.value;
        final double progressHeight = widget.expandedHeight - widget.height;
        final double currentHeight = widget.height + progressHeight * progress;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: currentHeight),
          child: DraggableScrollableSheet(
            controller: widget.controller,
            expand: false,
            initialChildSize: 0.0,
            minChildSize: 0.0,
            snap: true,
            snapAnimationDuration: _duration * 0.64,
            builder: (context, controller) {
              return ClipRect(
                child: OverflowBox(
                  maxHeight: currentHeight,
                  alignment: Alignment.topCenter,
                  child: DraggableBox(
                    controller: widget.controller,
                    child: PrimaryScrollController(controller: controller, child: sheet),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
