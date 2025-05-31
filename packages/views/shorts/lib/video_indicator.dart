import 'package:flutter/material.dart';
import 'package:shorts_view/core/duration.dart';
import 'package:ui_kit/animated_off_stage.dart';

import 'bloc/video_player_state.dart';

class VideoIndicator extends StatelessWidget {
  const VideoIndicator({super.key, required this.playerState});

  final VideoPlayerState playerState;

  double get videoRatio {
    final duration = playerState.duration?.inMilliseconds;
    if (duration == null || duration == 0) {
      return 0.0;
    }
    return (playerState.position?.inMilliseconds ?? 0) / duration;
  }

  double? get dragRatio {
    final duration = playerState.duration?.inMilliseconds;

    if (duration != null && duration != 0) {
      return (playerState.dragPosition.inMilliseconds) / duration;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool dragging = playerState.isDragging;

    bool showDragBar = dragging;
    bool showLoading = !showDragBar && playerState.loading && !playerState.seeking;
    bool showProgressBar = !showLoading;
    bool highlightProgressBar = showProgressBar && (!playerState.isPlaying || dragging);

    double barHeight = dragging
        ? 8
        : highlightProgressBar
            ? 4
            : 2;

    Widget bar = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        height: barHeight,
        child: Stack(
          children: [
            Offstage(offstage: !showLoading, child: LoadingBar(loading: showLoading)),
            Offstage(
              offstage: !showProgressBar,
              child: Container(color: Colors.white.withAlpha(50)),
            ),
            Offstage(
              offstage: !showProgressBar,
              child: IndicatorBar(
                duration: Duration(milliseconds: (1000 / 24).toInt()),
                ratio: videoRatio,
                color: Colors.white.withAlpha(highlightProgressBar ? 200 : 50),
              ),
            ),
            Offstage(
              offstage: !showDragBar,
              child: IndicatorBar(ratio: dragRatio ?? 0.0, color: Colors.white.withAlpha(100)),
            ),
          ],
        ),
      ),
    );

    Widget dot = AnimatedContainer(
      duration: Duration(milliseconds: 100),
      height: barHeight + 2,
      width: 4,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.white),
    );

    Widget time = AnimatedOpacityOffStage(
      duration: Duration(milliseconds: 200),
      opacity: dragging ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.only(bottom: dragging ? 60 : 20),
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 18),
            text: "${playerState.dragPosition.formattedString} / ",
            children: [TextSpan(text: playerState.duration?.formattedString)],
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        time,
        SizedBox(
          height: barHeight + 2,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [bar, Positioned(left: 20, child: dot)],
          ),
        ),
        SizedBox(height: 4),
      ],
    );
  }
}

class IndicatorBar extends StatelessWidget {
  const IndicatorBar({
    super.key,
    required this.ratio,
    this.color = Colors.white,
    this.duration = const Duration(milliseconds: 0),
  });

  final double ratio;
  final Color color;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: color,
          height: constraints.maxHeight,
          width: constraints.maxWidth * ratio,
        );
      },
    );
  }
}

class LoadingBar extends StatefulWidget {
  const LoadingBar({super.key, required this.loading});

  final bool loading;

  @override
  State<LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<LoadingBar> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    if (widget.loading) {
      controller.repeat();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LoadingBar oldWidget) {
    if (widget.loading) {
      controller.repeat();
    } else {
      controller.value = 0.0;
      controller.stop();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withAlpha(20),
              Colors.white.withAlpha(140),
              Colors.white.withAlpha(20),
            ],
            stops: [0.0, 0.5, 1],
          ),
        ),
      ),
      builder: (context, child) {
        return Center(child: ClipRect(child: Align(widthFactor: controller.value, child: child)));
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
