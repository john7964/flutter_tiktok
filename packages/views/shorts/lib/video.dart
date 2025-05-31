import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts_view/bloc/video_player_bloc.dart';
import 'package:shorts_view/video_comment.dart';
import 'package:shorts_view/video_foreground.dart';
import 'package:shorts_view/video_seek_scope.dart';
import 'package:shorts_view/video_wrapper.dart';
import 'package:ui_kit/animated_off_stage.dart';
import 'package:ui_kit/basic.dart';
import 'package:ui_kit/media.dart';
import 'package:ui_kit/page_view.dart';
import 'package:ui_kit/slivers.dart';
import 'package:ui_kit/tabs.dart';

import 'bloc/video_player_events.dart';
import 'bloc/video_player_state.dart';

final List<String> videoSource = [
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
];

const Duration _duration = Duration(milliseconds: 100);

class Shorts extends StatefulWidget {
  const Shorts({super.key, required this.onRequestShowBar});

  final void Function({bool top, bool bottom}) onRequestShowBar;

  @override
  State<Shorts> createState() => _ShortsState();
}

class _ShortsState extends State<Shorts> with TickerProviderStateMixin {
  final double videoMinHeight = 150.0;
  late final TabController tabController;
  late final StreamController<double> dragStreamController;
  bool removeBottomPadding = true;

  void handleTabChange() => setState(() {});

  void handleDragUpdate(double offsetRatio) => dragStreamController.add(offsetRatio);

  void handleRemoveBottomPadding(bool remove) {
    removeBottomPadding = remove;
    setState(() {});
  }

  @override
  void initState() {
    tabController = TabController(length: videoSource.length, vsync: this);
    tabController.addListener(handleTabChange);
    dragStreamController = StreamController<double>.broadcast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget videos = TabBarView2(
      pageSnapping: false,
      physics: PageFixedDurationScrollPhysics(parent: BouncingScrollPhysics()),
      controller: tabController,
      axis: Axis.vertical,
      children: List.generate(videoSource.length, (index) {
        return PreventMedia(
          prevent: tabController.index != index || PreventMedia.of(context),
          child: VideoSkeleton(
            source: videoSource[index],
            dragStream: tabController.index == index ? dragStreamController.stream : null,
            requestRemoveBottomPadding: handleRemoveBottomPadding,
            onRequestShowBar: widget.onRequestShowBar,
          ),
        );
      }),
    );

    final Widget drag = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: DraggableIndicator(onChange: handleDragUpdate),
    );

    return Stack(
      children: [
        Align(alignment: Alignment.bottomCenter, child: drag),
        SafeArea(top: false, bottom: removeBottomPadding, child: videos),
      ],
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
    required this.requestRemoveBottomPadding,
    required this.onRequestShowBar,
  });

  final String source;
  final Stream<double>? dragStream;
  final ValueSetter<bool> requestRemoveBottomPadding;
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
  bool scrollable = false;
  bool showForeground = true;
  late final ScrollController scrollController;
  late final StreamController<double> dragStreamController;
  late final DraggableScrollableController dragController;

  void handleScroll([AnimationStatus? status]) {
    if (scrollController.offset == 0.0 && dragController.size == 0.0) {
      showForeground = true;
      scrollable = false;
      widget.requestRemoveBottomPadding(true);
      widget.onRequestShowBar();
      setState(() {});
    }
  }

  void handleShowRelatives() async {
    showForeground = false;
    scrollable = true;
    setState(() {});
    widget.onRequestShowBar(top: false);
    // scrollController.animateTo(offset, duration: _duration, curve: Curves.easeIn);
  }

  void handleShowComment(double ratio) {
    widget.requestRemoveBottomPadding(false);
    showForeground = false;
    widget.onRequestShowBar(top: false);
    setState(() {});
    dragController.animateTo(ratio, duration: _duration, curve: Curves.easeIn);
    // dragController.jumpTo(1.0);
  }

  void handleDismissed() async {
    FocusScope.of(context).unfocus();
    await Future.wait([
      scrollController.animateTo(0.0, duration: _duration, curve: Curves.easeOut),
      dragController.animateTo(0.0, duration: _duration, curve: Curves.easeOut),
    ]);
    widget.requestRemoveBottomPadding(true);
    widget.onRequestShowBar();
    showForeground = true;
    setState(() {});
  }

  void handleDragUpdate(double offsetRatio) {
    videoPlayerBloc!.add(IndicatorDraggingEvent(offsetRatio: offsetRatio));
  }

  @override
  void initState() {
    dragSubscription = widget.dragStream?.listen(handleDragUpdate);
    scrollController = ScrollController()..addListener(handleScroll);
    dragStreamController = StreamController<double>.broadcast();
    dragController = DraggableScrollableController();
    dragController.addListener(handleScroll);

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

    final header = SliverLayoutBuilder(builder: (context, constrains) {
      final double bottomPadding = MediaQuery.paddingOf(context).bottom;
      final double topPadding = MediaQuery.paddingOf(context).top;
      final double maxExtent = constrains.viewportMainAxisExtent;
      final double width = constrains.crossAxisExtent;
      final Size maxVideoSize = Size(width, maxExtent - bottomPadding);
      final Size minVideoSize = Size(width, maxExtent * videoMinHeightRatio);
      final double minVideoHeight = maxExtent * videoMinHeightRatio;
      final double minExtent = minVideoHeight + topPadding;
      final Tween<Size> sizeTween = Tween(begin: maxVideoSize, end: minVideoSize);

      final Widget video = LayoutBuilder(builder: (context, constraints) {
        final double maxOffset = maxVideoSize.height - minExtent;
        final double offset = maxVideoSize.height - constraints.maxHeight;
        final double scale = offset / maxOffset;
        return Column(
          children: [
            SizedBox(height: topPadding * scale),
            Flexible(child: VideoAspectRatio(scale: scale, tween: sizeTween)),
          ],
        );
      });

      final Widget foreground = AnimatedOpacityOffStage(
        opacity: showForeground ? 1.0 : 0.0,
        child: VideoForeground(
          onTapComments: () => handleShowComment(1.0),
          onTapText: handleShowRelatives,
        ),
      );

      final double scrollOffset = constrains.scrollOffset;
      final prevent = scrollOffset >= maxExtent || PreventMedia.of(context);
      return SliverPersistentHeaderBox(
        minExtent: minExtent,
        maxExtent: maxExtent,
        child: PreventMedia(
          prevent: prevent,
          child: Column(
            children: [
              ExpandedAlign(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxVideoSize.height),
                  child: GestureDetector(
                    onTap: handleDismissed,
                    child: AbsorbPointer(
                      absorbing: !showForeground,
                      child: Stack(children: [video, foreground]),
                    ),
                  ),
                ),
              ),
              CommentsSheet(
                controller: dragController,
                height: maxExtent - minExtent,
                expandedHeight: maxExtent - topPadding,
              ),
            ],
          ),
        ),
      );
    });

    return BlocProvider.value(
      value: videoPlayerBloc!,
      child: NestedScrollView(
        controller: scrollController,
        physics: scrollable ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
        headerSliverBuilder: (context, scrolled) => [header],
        body: Builder(builder: (context) {
          return CustomScrollView(
            physics: scrollable ? null : NeverScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(pinned: true, title: Text("data")),
              SliverToBoxAdapter(child: Container(height: 1000, color: Colors.white)),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    videoPlayerBloc?.close();
    dragSubscription?.cancel();
    super.dispose();
  }
}
