import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts_view/prevent_scroll.dart';
import 'package:shorts_view/bloc/video_player_bloc.dart';
import 'package:shorts_view/video_comment.dart';
import 'package:shorts_view/video_foreground.dart';
import 'package:shorts_view/video_seek_scope.dart';
import 'package:shorts_view/video_wrapper.dart';
import 'package:ui_kit/basic.dart';
import 'package:ui_kit/media.dart';
import 'package:ui_kit/page_view.dart';

import 'bloc/video_player_events.dart';
import 'bloc/video_player_state.dart';

final List<String> videoSource = [
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
];

const Duration _duration = Duration(milliseconds: 120);

class Shorts extends StatefulWidget {
  const Shorts({super.key, required this.onRequestShowBar});

  final void Function({bool top, bool bottom}) onRequestShowBar;

  @override
  State<Shorts> createState() => _ShortsState();
}

class _ShortsState extends State<Shorts> with TickerProviderStateMixin {
  final double videoMinHeight = 150.0;
  late final PageController tabController;
  late final StreamController<double> dragStreamController;
  bool removeBottomPadding = false;
  int currentPage = 0;
  double? foregroundOpacity;

  void handleTabChange() {
    final bool isScrolling = (tabController.page ?? 0.0).ceilToDouble() != tabController.page;
    if (isScrolling != removeBottomPadding) {
      removeBottomPadding = isScrolling;
      setState(() {});
    }
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return true;
    }

    if (notification is ScrollStartNotification) {
      setState(() {
        removeBottomPadding = true;
      });
    } else if (notification is ScrollEndNotification) {
      setState(() {
        currentPage = tabController.page!.round();
        removeBottomPadding = false;
      });
    } else if (notification is UserScrollNotification) {
      foregroundOpacity = notification.direction == ScrollDirection.idle ? null : 0.3;
      setState(() {});
    }
    return false;
  }

  void handleDragUpdate(double offsetRatio) => dragStreamController.add(offsetRatio);

  @override
  void initState() {
    tabController = PageController();
    dragStreamController = StreamController<double>.broadcast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final videos = NotificationListener<ScrollNotification>(
      onNotification: handleScrollNotification,
      child: PageView2(
        pageSnapping: false,
        physics: const PageFixedDurationScrollPhysics(parent: BouncingScrollPhysics()),
        controller: tabController,
        scrollDirection: Axis.vertical,
        hitTestBehavior: HitTestBehavior.translucent,
        children: List.generate(videoSource.length, (index) {
          final bool isCurrent = currentPage == index;
          return PreventMedia(
            prevent: !isCurrent || PreventMedia.of(context),
            child: VideoSkeleton(
              source: videoSource[index],
              dragStream: dragStreamController.stream,
              foregroundOpacity: isCurrent ? foregroundOpacity : null,
              onRequestShowBar: widget.onRequestShowBar,
            ),
          );
        }),
      ),
    );

    final Widget drag = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: DraggableIndicator(onChange: handleDragUpdate),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Align(alignment: Alignment.bottomCenter, child: drag),
          SafeArea(top: false, bottom: removeBottomPadding, child: videos),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}

class VideoSkeleton extends StatefulWidget {
  const VideoSkeleton({
    super.key,
    required this.source,
    required this.dragStream,
    required this.foregroundOpacity,
    required this.onRequestShowBar,
  });

  final String source;
  final Stream<double>? dragStream;
  final double? foregroundOpacity;
  final void Function({bool top, bool bottom}) onRequestShowBar;

  @override
  State<VideoSkeleton> createState() => _VideoSkeletonState();
}

const double videoMinHeightRatio = 1 / 5;
const double videoMinWidthRatio = 1 / 2;

class _VideoSkeletonState extends State<VideoSkeleton>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  Bloc<dynamic, VideoPlayerState>? videoPlayerBloc;
  StreamSubscription<double>? dragSubscription;
  @override
  bool wantKeepAlive = true;
  late final StreamController<double> dragStreamController;
  late final DraggableScrollableController commentsController;
  late final DraggableScrollableController relativesController;
  double foregroundOpacity = 1.0;
  bool absorbingForeground = false;
  bool preventParentScroll = false;

  void toggleImmersiveMode(bool immersive) {
    absorbingForeground = immersive;
    preventParentScroll = immersive;
    widget.onRequestShowBar(top: !immersive);
    setState(() {});
  }

  void handleScroll([AnimationStatus? status]) {
    if (commentsController.size == 0.0) {
      toggleImmersiveMode(false);
      setState(() {});
    }
  }

  void handleShowComment() {
    toggleImmersiveMode(true);
    commentsController.animateTo(1.0, duration: _duration, curve: Curves.easeOutSine);
  }

  void handleDismissed() async {
    toggleImmersiveMode(false);
    FocusScope.of(context).unfocus();
    await Future.wait([
      commentsController.animateTo(0.0, duration: _duration, curve: Curves.easeOutSine),
    ]);
  }

  void handleDragUpdate(double offsetRatio) {
    videoPlayerBloc!.add(IndicatorDraggingEvent(offsetRatio: offsetRatio));
  }

  @override
  void initState() {
    dragSubscription = widget.dragStream?.listen(handleDragUpdate);
    dragStreamController = StreamController<double>.broadcast();
    commentsController = DraggableScrollableController();
    commentsController.addListener(handleScroll);

    videoPlayerBloc = VideoPlayerBloc(source: widget.source);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoSkeleton oldWidget) {
    if (oldWidget.source != widget.source) {
      videoPlayerBloc?.close();
      videoPlayerBloc = VideoPlayerBloc(source: widget.source);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final header = LayoutBuilder(builder: (context, constrains) {
      final double bottomPadding = MediaQuery.paddingOf(context).bottom;
      final double topPadding = MediaQuery.paddingOf(context).top;
      final double maxExtent = constrains.maxHeight;
      final double width = constrains.maxWidth;
      final Size maxVideoSize = Size(width, maxExtent - bottomPadding);
      final Size minVideoSize = Size(width, maxExtent * videoMinHeightRatio);
      final double minVideoHeight = maxExtent * videoMinHeightRatio;
      final double minExtent = minVideoHeight + topPadding;
      final Tween<Size> sizeTween = Tween(begin: maxVideoSize, end: minVideoSize);

      final Widget foreground = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxVideoSize.height),
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: maxVideoSize.height,
          child: PreventScroll(
            onTap: handleDismissed,
            prevent: preventParentScroll,
            child: AbsorbPointer(
              absorbing: absorbingForeground,
              child: VideoForeground(
                onTapComments: handleShowComment,
                onTapText: () {},
                opacity: widget.foregroundOpacity ?? foregroundOpacity,
              ),
            ),
          ),
        ),
      );

      final Widget video = LayoutBuilder(builder: (context, constraints) {
        final double maxOffset = maxExtent - minExtent;
        final double offset = maxExtent - constraints.maxHeight;
        final double scale = offset / maxOffset;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxVideoSize.height),
          child: Column(
            children: [
              SizedBox(height: topPadding * scale),
              Flexible(child: VideoAspectRatio(scale: scale, tween: sizeTween)),
            ],
          ),
        );
      });

      // final double scrollOffset = constrains.scrollOffset;
      // final prevent = scrollOffset >= maxExtent || PreventMedia.of(context);
      return Column(
        children: [
          ExpandedAlign(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [video, foreground],
            ),
          ),
          CommentsSheet(
            controller: commentsController,
            height: maxExtent - minExtent,
            expandedHeight: maxExtent - topPadding,
          ),
        ],
      );
    });

    return BlocProvider.value(value: videoPlayerBloc!, child: header);
  }

  @override
  void dispose() {
    videoPlayerBloc?.close();
    dragSubscription?.cancel();
    super.dispose();
  }
}
