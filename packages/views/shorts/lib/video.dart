import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts_view/bloc/video_player_bloc.dart';
import 'package:shorts_view/video_indicator.dart';
import 'package:shorts_view/video_wrapper.dart';
import 'package:ui_kit/media.dart';

import 'bloc/video_player_events.dart';
import 'bloc/video_player_state.dart';
import 'core/animated_off_stage.dart';
import 'core/draggable_contrainer.dart';

class ShortsView extends StatefulWidget {
  const ShortsView({super.key});

  @override
  State<ShortsView> createState() => _ShortsViewState();
}

class _ShortsViewState extends State<ShortsView> {
  @override
  Widget build(BuildContext context) {
    Widget child = VideoSkeleton(
      source:
          "https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4",
    );
    // if (Scaffold.maybeOf(context) == null) {
    //   child = Scaffold(backgroundColor: Colors.black, body: child);
    // }

    return child;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class VideoSkeleton extends StatefulWidget {
  const VideoSkeleton({super.key, required this.source});

  final String source;

  @override
  State<VideoSkeleton> createState() => _VideoSkeletonState();
}

class _VideoSkeletonState extends State<VideoSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  bool dragged = false;
  bool isPaused = false;
  late AnimationStatus bottomSheetStatus;
  late final VideoPlayerBloc videoPlayerBloc;

  void handleDragChange(bool value) => setState(() => dragged = value);

  void handleTapComments() => animationController.forward();

  void handleTapText() => animationController.forward();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    bottomSheetStatus = animationController.status;
    animationController.addListener(
      () => setState(() => bottomSheetStatus = animationController.status),
    );
    videoPlayerBloc = VideoPlayerBloc(source: widget.source, preventMedia: false);
  }

  @override
  void didChangeDependencies() {
    videoPlayerBloc.add(PreventMediaUpdatedEvent(prevent: PreventMedia.of(context)));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    final Widget backgroundWidget = LayoutBuilder(
      builder: (context, constrains) {
        return Column(
          children: [
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return SizedBox(height: topPadding * animationController.value);
              },
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: animationController.reverse,
                child: IgnorePointer(
                  ignoring: bottomSheetStatus != AnimationStatus.dismissed,
                  child: const VideoPlayerWrapper(),
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(minHeight: bottomPadding),
              alignment: Alignment.bottomCenter,
              child: DraggableBox(
                alignment: Alignment.topCenter,
                controller: animationController,
                child: Container(
                  height: constrains.maxHeight - 200,
                  decoration: ShapeDecoration(
                    color: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                  child: Column(children: [Container(height: 100, color: Colors.green)]),
                ),
              ),
            ),
          ],
        );
      },
    );

    final Widget foregroundWidget = Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: VideoLeftInfo(onTextTap: handleTapText)),
              SizedBox(width: 64),
              VideoRightBar(onTapComments: handleTapComments),
            ],
          ),
        ),
      ),
    );

    final Widget indicator = Offstage(
      offstage: bottomSheetStatus != AnimationStatus.dismissed,
      child: BlocBuilder<Bloc<dynamic, VideoPlayerState>, VideoPlayerState>(
        bloc: videoPlayerBloc,
        builder: (context, state) {
          return VideoIndicator(
            dragging: dragged,
            onDragChange: handleDragChange,
            playerState: state,
          );
        },
      ),
    );

    return BlocProvider<Bloc<dynamic, VideoPlayerState>>(
      create: (context) => videoPlayerBloc,
      child: Stack(
        children: [
          backgroundWidget,
          AnimatedOpacityOffStage(
            opacity: bottomSheetStatus == AnimationStatus.dismissed && !dragged ? 1.0 : 0.0,
            child: SafeArea(top: false, child: foregroundWidget),
          ),
          Positioned(bottom: bottomPadding, left: 16, right: 16, child: indicator),
        ],
      ),
    );
  }

  @override
  void dispose() {
    videoPlayerBloc.close();
    super.dispose();
  }
}

class VideoLeftInfo extends StatelessWidget {
  const VideoLeftInfo({super.key, required this.onTextTap});

  final VoidCallback onTextTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTextTap,
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.white),
        child: Text(
          "asdasdasdasdssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssasd",
        ),
      ),
    );
  }
}

class VideoRightBar extends StatelessWidget {
  const VideoRightBar({super.key, required this.onTapComments});

  final VoidCallback onTapComments;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Colors.white, size: 30),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.white, fontSize: 12),
        child: UnconstrainedBox(
          child: Wrap(
            direction: Axis.vertical,
            spacing: 24,
            children: [
              Column(
                children: [Icon(CupertinoIcons.heart_fill), SizedBox(height: 4), Text("222.9K")],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTapComments,
                child: Column(
                  children: [
                    Icon(CupertinoIcons.chat_bubble_text_fill),
                    SizedBox(height: 4),
                    Text("222.9K"),
                  ],
                ),
              ),
              Column(
                children: [Icon(Icons.bookmark_add_rounded), SizedBox(height: 4), Text("222.9K")],
              ),
              Column(
                children: [
                  Icon(CupertinoIcons.reply_thick_solid),
                  SizedBox(height: 4),
                  Text("222.9K"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
