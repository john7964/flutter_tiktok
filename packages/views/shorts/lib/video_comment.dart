import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'core/draggable_contrainer.dart';

class VideoCommentsList extends StatefulWidget {
  const VideoCommentsList({
    super.key,
    required this.controller,
    this.physics,
    required this.expanded,
    required this.onExpandedChange,
  });

  final ScrollController controller;
  final ScrollPhysics? physics;
  final bool expanded;
  final ValueSetter<bool> onExpandedChange;

  @override
  State<VideoCommentsList> createState() => _VideoCommentsListState();
}

class _VideoCommentsListState extends State<VideoCommentsList> {
  final List<GlobalKey> keys = List.generate(20, (index) => GlobalKey());
  final FocusNode focusNode = FocusNode();

  ScrollController get scrollController => widget.controller;

  GlobalKey? _lastFocusedKey;
  double _lastScrollOffset = 0.0;

  void handleFocusChange() {
    if (focusNode.hasFocus) {
      _lastScrollOffset = scrollController.offset;
    } else {
      scrollController.animateTo(
        _lastScrollOffset,
        duration: Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    // focusNode.addListener(handleFocusChange);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (focusNode.hasFocus) {
      final RenderSliver? renderSliver =
          _lastFocusedKey?.currentContext?.findRenderObject() as RenderSliver?;
      final double remainingExtent = renderSliver?.constraints.remainingPaintExtent ?? 0.0;
      final double maxPaintExtent = renderSliver?.geometry?.maxPaintExtent ?? 0.0;
      final double scrollOffset = maxPaintExtent - remainingExtent;
      if (scrollOffset > 0) {
        scrollController.jumpTo(scrollController.offset + scrollOffset);
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
        padding: EdgeInsets.symmetric(horizontal: 8),
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
                controller: scrollController,
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
                        child: SizedBox(
                          height: 100,
                          child: Center(child: Text("${key.hashCode}")),
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

const Duration _duration = Duration(milliseconds: 100);

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
            snapSizes: [0.0, 1.0],
            snapAnimationDuration: _duration * 0.64,
            builder: (context, controller) {
              return ClipRect(
                child: OverflowBox(
                  maxHeight: currentHeight,
                  alignment: Alignment.topCenter,
                  child: DraggableBox(
                    controller: widget.controller,
                    child: VideoCommentsList(
                      controller: controller,
                      expanded: expanded,
                      onExpandedChange: handleCommentsExpand,
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
