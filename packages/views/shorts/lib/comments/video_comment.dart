import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shorts_view/comments/comments_sliver_list.dart';
import 'package:ui_kit/animated_off_stage.dart';
import 'package:ui_kit/theme/theme.dart';

class VideoCommentsList extends StatefulWidget {
  const VideoCommentsList({super.key, this.physics});

  final ScrollPhysics? physics;
  // final AnimationController expandAnimation;

  @override
  State<VideoCommentsList> createState() => _VideoCommentsListState();
}

class _VideoCommentsListState extends State<VideoCommentsList> {
  final GlobalKey<SliverAnimatedListState> sliverListKey = GlobalKey();

  final FocusNode textFieldFocusNode = FocusNode();
  final ScrollController _defaultController = ScrollController();
  late ScrollController controller;
  final ValueNotifier<GlobalKey?> selectedItem = ValueNotifier(null);
  final List<GlobalKey> keys = comments.map((item) => GlobalKey()).toList();

  void handleCommentTap(GlobalKey key) => selectedItem.value = key;

  @override
  void didChangeDependencies() {
    controller = PrimaryScrollController.maybeOf(context) ?? _defaultController;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Widget header = Builder(builder: (context) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              "13条评论",
              style: TextTheme.of(context).titleSmall?.copyWith(fontSize: 13),
            ),
          ),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: IconButton(onPressed: handleCommentsExpand, icon: Icon(Icons.fullscreen)),
          // )
        ],
      );
    });

    final Widget textField = TextField(
      focusNode: textFieldFocusNode,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        hintText: "评论",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color(0xFFF5F5F5),
      ),
      style: TextStyle(fontSize: 14, color: Colors.black87),
    );

    final Widget list = CommentsSliverList(
      listKey: sliverListKey,
      onTapComment: handleCommentTap,
      scrollController: controller,
      parentComments: comments,
    );

    return Theme(
      data: lightTheme,
      child: CommentsFocusScope(
        header: header,
        list: list,
        textField: textField,
        focusNode: textFieldFocusNode,
        selectedKey: selectedItem,
        sliverKey: sliverListKey,
        scrollController: controller,
      ),
    );
  }

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    super.dispose();
  }
}

class CommentsFocusScope extends StatefulWidget {
  const CommentsFocusScope({
    super.key,
    required this.header,
    required this.list,
    required this.textField,
    required this.focusNode,
    required this.selectedKey,
    required this.sliverKey,
    required this.scrollController,
  });

  final Widget header;
  final Widget list;
  final Widget textField;
  final FocusNode focusNode;
  final ValueNotifier<GlobalKey?> selectedKey;
  final GlobalKey sliverKey;
  final ScrollController scrollController;

  @override
  State<CommentsFocusScope> createState() => _CommentsFocusScopeState();
}

class _CommentsFocusScopeState extends State<CommentsFocusScope> {
  late bool hasFocus;
  double _lastScrollOffset = 0.0;

  void handleFocusChanged() {
    hasFocus = widget.focusNode.hasFocus;
    setState(() {});
  }

  void handleSelectedItemChanged() {
    if (widget.selectedKey.value != null) {
      widget.focusNode.requestFocus();
      _lastScrollOffset = widget.scrollController.offset;
    }
  }

  @override
  void initState() {
    hasFocus = widget.focusNode.hasFocus;
    widget.focusNode.addListener(handleFocusChanged);
    widget.selectedKey.addListener(handleSelectedItemChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CommentsFocusScope oldWidget) {
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(handleFocusChanged);
      hasFocus = widget.focusNode.hasFocus;
      widget.focusNode.addListener(handleFocusChanged);
    }
    if (widget.selectedKey != oldWidget.selectedKey) {
      oldWidget.selectedKey.removeListener(handleSelectedItemChanged);
      widget.selectedKey.addListener(handleSelectedItemChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.selectedKey.value == null) {
      return;
    }
    final RenderBox parentSliver = widget.sliverKey.currentContext?.findRenderObject() as RenderBox;
    final BuildContext? context = widget.selectedKey.value!.currentContext;
    final RenderBox? renderBox = context?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    final Offset offset = renderBox.localToGlobal(Offset(0.0, 0.0), ancestor: parentSliver);
    final double remainingExtent = parentSliver.size.height;
    final double scrollOffset =
        widget.scrollController.offset + (offset.dy + renderBox.size.height - remainingExtent);
    widget.scrollController.jumpTo(max(scrollOffset, _lastScrollOffset));
    if (!widget.focusNode.hasFocus && scrollOffset <= _lastScrollOffset) {
      widget.selectedKey.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final bottomInsets = MediaQuery.viewInsetsOf(context).bottom;
    return GestureDetector(
      onTap: () => widget.focusNode.unfocus(),
      child: Material(
        color: Colors.white,
        child: Column(children: [
          Expanded(
            child: AbsorbPointer(
              absorbing: widget.focusNode.hasFocus,
              child: Stack(
                children: [
                  Column(children: [widget.header, Expanded(child: widget.list)]),
                  AnimatedOpacityOffStage(
                    opacity: hasFocus ? 0.26 : 0.0,
                    duration: Duration(milliseconds: 240),
                    child: Container(color: Colors.black),
                  )
                ],
              ),
            ),
          ),
          FocusScope(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: widget.textField,
            ),
          ),
          SizedBox(height: bottomInsets + bottomPadding)
        ]),
      ),
    );
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(handleFocusChanged);
    widget.selectedKey.removeListener(handleSelectedItemChanged);
    super.dispose();
  }
}
