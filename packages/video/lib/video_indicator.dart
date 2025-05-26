import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts/core/duration.dart';

import 'bloc/video_player_events.dart';
import 'bloc/video_player_state.dart';
import 'core/animated_off_stage.dart';
import 'core/draggable_builder.dart';

class VideoIndicator extends StatefulWidget {
  const VideoIndicator({
    super.key,
    required this.dragging,
    required this.onDragChange,
    required this.playerState,
  });

  final bool dragging;
  final void Function(bool dragged) onDragChange;
  final VideoPlayerState playerState;

  @override
  State<VideoIndicator> createState() => _VideoIndicatorState();
}

class _VideoIndicatorState extends State<VideoIndicator> {
  late double dragRatio = 0.0;

  double get videoRatio {
    final duration = widget.playerState.duration?.inMilliseconds;
    if (duration == null || duration == 0) {
      return 0.0;
    }
    return widget.playerState.position.inMilliseconds / duration;
  }

  Duration get dragDuration {
    return Duration(
      milliseconds: ((widget.playerState.duration?.inMilliseconds ?? 0) * dragRatio).toInt(),
    );
  }

  void _handleDragStart() {
    widget.onDragChange(true);
    dragRatio = videoRatio;
  }

  void _handleDragUpdate(double offsetRatio) {
    setState(() => dragRatio = max(0, dragRatio + offsetRatio));
  }

  void _handleDragEnd() async {
    widget.onDragChange(false);
    context.read<Bloc<dynamic, VideoPlayerState>>().add(SeekToEvent(dragDuration));
  }

  @override
  Widget build(BuildContext context) {
    bool showDragBar = widget.dragging;
    bool showLoading = !showDragBar && widget.playerState.loading && !widget.playerState.seeking;
    bool showProgressBar = !showLoading;
    bool highlightProgressBar =
        showProgressBar && (!widget.playerState.isPlaying || widget.dragging);

    double barHeight =
        widget.dragging
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
              child: IndicatorBar(ratio: dragRatio, color: Colors.white.withAlpha(100)),
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
      opacity: widget.dragging ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.only(bottom: widget.dragging ? 60 : 20),
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 18),
            text: "${dragDuration.formattedString} / ",
            children: [TextSpan(text: widget.playerState.duration?.formattedString)],
          ),
        ),
      ),
    );

    return DraggableBar(
      onDragStart: _handleDragStart,
      onDragUpdate: _handleDragUpdate,
      onDragEnd: _handleDragEnd,
      child: Column(
        children: [
          time,
          SizedBox(
            height: barHeight + 2,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [bar, Positioned(left: 20, child: dot)],
            ),
          ),
        ],
      ),
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
