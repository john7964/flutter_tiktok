import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'core/draggable_contrainer.dart';

class VideoCommentsList extends StatefulWidget {
  const VideoCommentsList({
    super.key,
    this.physics,
    required this.expanded,
    required this.onExpandedChange,
  });

  final ScrollPhysics? physics;
  final bool expanded;
  final ValueSetter<bool> onExpandedChange;

  @override
  State<VideoCommentsList> createState() => _VideoCommentsListState();
}

class _VideoCommentsListState extends State<VideoCommentsList> {
  final List<GlobalKey> keys = List.generate(20, (index) => GlobalKey());
  final FocusNode focusNode = FocusNode();
  final ScrollController _defaultController = ScrollController();
  late ScrollController controller;

  GlobalKey? _lastFocusedKey;
  double _lastScrollOffset = 0.0;

  void handleFocusChange() {
    if (focusNode.hasFocus) {
      _lastScrollOffset = controller.offset;
    } else {
      controller.animateTo(
        _lastScrollOffset,
        duration: Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didChangeDependencies() {
    controller = PrimaryScrollController.maybeOf(context) ?? _defaultController;
    super.didChangeDependencies();
    if (focusNode.hasFocus) {
      final RenderSliver? renderSliver =
          _lastFocusedKey?.currentContext?.findRenderObject() as RenderSliver?;
      final double remainingExtent = renderSliver?.constraints.remainingPaintExtent ?? 0.0;
      final double maxPaintExtent = renderSliver?.geometry?.maxPaintExtent ?? 0.0;
      final double scrollOffset = maxPaintExtent - remainingExtent;
      if (scrollOffset > 0) {
        controller.jumpTo(controller.offset + scrollOffset);
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bottom =
        max(MediaQuery.viewPaddingOf(context).bottom, MediaQuery.viewInsetsOf(context).bottom);
    final focus = FocusScope.of(context).hasFocus;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Center(child: Text("13条评论")),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => widget.onExpandedChange(!widget.expanded),
                    icon: Icon(Icons.fullscreen),
                  ),
                )
              ],
            ),
            Expanded(
              child: CustomScrollView(
                primary: false,
                controller: controller,
                physics:
                    widget.physics?.applyTo(BouncingScrollPhysics()) ?? BouncingScrollPhysics(),
                slivers: [
                  ...keys.map((key) {
                    return SliverToBoxAdapter(
                      key: key,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          focusNode.requestFocus();
                          _lastFocusedKey = key;
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Comment(),
                        ),
                      ),
                    );
                  })
                ],
              ),
            ),
            TextField(
              focusNode: focusNode,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                hintText: "评论",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: bottom)
          ],
        ),
      ),
    );
  }
}

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

const Duration _duration = Duration(milliseconds: 120);

class _CommentsSheetState extends State<CommentsSheet> with SingleTickerProviderStateMixin {
  late bool expanded = false;
  late final AnimationController expandController = AnimationController(
    vsync: this,
    duration: _duration,
  );

  void handleCommentsExpand(bool expanded) {
    this.expanded = expanded;
    if (expanded) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                    child: PrimaryScrollController(
                      controller: controller,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                        child: VideoCommentsList(
                          expanded: expanded,
                          onExpandedChange: handleCommentsExpand,
                        ),
                      ),
                    ),
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

class Comment extends StatelessWidget {
  const Comment({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: Container(height: 36, width: 36, color: Colors.amber),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "胰液素风",
                maxLines: 1,
                style: TextStyle(color: Color(0xFFA4A6A8), fontSize: 13),
              ),
              SizedBox(height: 4),
              Text("不敢吹其他人", style: TextStyle(
                  fontFamilyFallback: ["PingFang SC"],
                  fontSize: 14.5,fontWeight: FontWeight.w400,color: Color(0xFF030300))),
              SizedBox(height: 4),
              Row(children: [
                Text("4-24 内蒙古", style: TextStyle(color: Color(0xFFA4A6A8), fontSize: 13)),
                Spacer(),
                Icon(CupertinoIcons.heart, size: 16)
              ])
            ],
          ),
        )
      ],
    );
  }
}
