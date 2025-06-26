import 'package:flutter/material.dart';
import 'package:shorts_view/comments/video_comment.dart';
import 'package:ui_kit/route/draggable_scrollable_route.dart';
import '../core/draggable_contrainer.dart';

const Duration _duration = Duration(milliseconds: 120);

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
  });


  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> with SingleTickerProviderStateMixin {
  late final AnimationController expandController = AnimationController(
    vsync: this,
    duration: _duration,
  );

  late DraggableScrollableController controller;

  @override
  void didChangeDependencies() {
    controller = DraggableScrollableRoute.of(context).controller;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Widget sheet = ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      child: VideoCommentsList(),
    );

    return LayoutBuilder(builder: (context, constraints) {
      return DraggableScrollableSheet(
        controller: controller,
        initialChildSize: 0.0,
        minChildSize: 0.0,
        maxChildSize: 0.7,
        snap: true,
        snapAnimationDuration: _duration * 0.64,
        builder: (context, controller) {
          return ClipRRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: constraints.maxHeight * 0.7,
              child: DraggableBox(
                controller: this.controller,
                child: PrimaryScrollController(controller: controller, child: sheet),
              ),
            ),
          );
        },
      );
    });
  }
}
