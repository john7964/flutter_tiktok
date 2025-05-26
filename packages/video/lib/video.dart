import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts/bloc/video_player_bloc.dart';
import 'package:shorts/video_indicator.dart';
import 'package:shorts/video_wrapper.dart';

import 'bloc/video_player_state.dart';
import 'core/animated_off_stage.dart';
import 'core/draggable_contrainer.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class ShortsView extends StatefulWidget {
  const ShortsView({super.key});

  @override
  State<ShortsView> createState() => _ShortsViewState();
}

class _ShortsViewState extends State<ShortsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar: Container(height: 40));
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

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    bottomSheetStatus = animationController.status;
    animationController.addListener(
      () => setState(() => bottomSheetStatus = animationController.status),
    );
  }

  void handleDragChange(bool value) => setState(() => dragged = value);

  void handleTapComments() => animationController.forward();

  void handleTapText() => animationController.forward();

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

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

    final Widget foregroundWidget = SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: AnimatedOpacityOffStage(
            opacity: bottomSheetStatus == AnimationStatus.dismissed && !dragged ? 1.0 : 0.0,
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
      ),
    );

    final Widget indicator = Offstage(
      offstage: bottomSheetStatus != AnimationStatus.dismissed,
      child: BlocBuilder<Bloc<dynamic, VideoPlayerState>, VideoPlayerState>(
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
      create: (context) => VideoPlayerBloc(widget.source),
      child: Stack(
        children: [
          backgroundWidget,
          SafeArea(top: false, child: foregroundWidget),
          Positioned(bottom: bottomPadding, left: 16, right: 16, child: indicator),
        ],
      ),
    );
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
