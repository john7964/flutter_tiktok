import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ui_kit/animated_off_stage.dart';
import 'package:ui_kit/appbar_manager.dart';
import 'package:ui_kit/route/draggable_route.dart';

import 'short_foreground.dart';
import '../core/video_aspect_ratio.dart';

class VideoSkeleton extends StatefulWidget {
  const VideoSkeleton({super.key});

  @override
  State<VideoSkeleton> createState() => _VideoSkeletonState();
}

const double videoMinHeightRatio = 1 / 5;
const double videoMinWidthRatio = 1 / 2;

class _VideoSkeletonState extends State<VideoSkeleton>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool wantKeepAlive = true;
  final FocusScopeNode focusScopeNode = FocusScopeNode();
  late final StreamController<double> dragStreamController;
  late ValueNotifier<double>? resizingFraction;

  // late final DraggableScrollableController commentsController;
  late final DraggableScrollableController relativesController;
  double foregroundOpacity = 1.0;

  void toggleImmersiveMode(bool immersive) {
    AppBarManager.maybeOf(context)?.changeAppBar(top: !immersive);
  }

  void handleScroll([AnimationStatus? status]) {
    // if (commentsController.size == 0.0) {
    //   toggleImmersiveMode(false);
    // }
  }

  void handleShowComment() async {
    toggleImmersiveMode(true);
    // await commentsController.animateTo(1.0, duration: _duration, curve: Curves.easeIn);
  }

  void handleDismissed() async {
    toggleImmersiveMode(false);
    FocusScope.of(context, createDependency: false).unfocus();
    await Future.wait([
      // commentsController.animateToeTo(0.0, duration: _duration, curve: Curves.easeOut),
    ]);
  }

  @override
  void didChangeDependencies() {
    resizingFraction = DraggableResizedRoute.maybeOf(context)?.fraction;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(builder: (context, constrains) {
      final double topPadding = MediaQuery.viewPaddingOf(context).top;
      final double maxVideoHeight = constrains.maxHeight;
      final double minVideoHeight = maxVideoHeight * videoMinHeightRatio + topPadding;
      final double maxWidth = constrains.maxWidth;

      final Widget foreground = Container(
        constraints: BoxConstraints(maxHeight: maxVideoHeight),
        child: AnimatedOpacityOffStage(
          opacity: foregroundOpacity,
          child: VideoForeground(onTapComments: handleShowComment, onTapText: () {}),
        ),
      );

      // final Widget drag = Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 12.0),
      //   child: DraggableIndicator(onChange: handleDragUpdate),
      // );

      final Widget tools = ValueListenableBuilder(
        valueListenable: DraggableResizedRoute.maybeOf(context)?.fraction ?? ValueNotifier(1.0),
        builder: (context, value, child) => Offstage(offstage: value != 1.0, child: child),
        child: OverflowBox(
          maxHeight: maxVideoHeight,
          minHeight: 0.0,
          alignment: Alignment.topCenter,
          child: Stack(
            children: [
              Align(alignment: Alignment.topCenter, child: foreground),
              // Align(alignment: Alignment.bottomCenter, child: drag),
            ],
          ),
        ),
      );

      final BoxConstraints beginConstrains = BoxConstraints(
        minWidth: maxWidth,
        maxWidth: maxWidth,
        minHeight: 0.0,
        maxHeight: maxVideoHeight,
      );

      final BoxConstraints endConstrains = BoxConstraints(
        minWidth: 150,
        maxWidth: maxWidth,
        minHeight: 0.0,
        maxHeight: minVideoHeight,
      );
      final EdgeInsets beginPadding = EdgeInsets.zero;
      final EdgeInsets endPadding = EdgeInsets.only(top: topPadding);
      final EdgeInsetsTween paddingTween = EdgeInsetsTween(begin: beginPadding, end: endPadding);
      final Widget video = VideoAspectRatio(
        beginConstrains: beginConstrains,
        endEndConstrains: endConstrains,
        paddingTween: paddingTween,
      );

      return Stack(fit: StackFit.expand, children: [video, tools]);
    });
  }
}
