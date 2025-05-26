import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'bloc/video_player_bloc.dart';
import 'bloc/video_player_events.dart';
import 'bloc/video_player_state.dart';
import 'core/animated_off_stage.dart';

class VideoPlayerWrapper extends StatelessWidget {
  const VideoPlayerWrapper({super.key});

  void handleTapVideo(BuildContext context) {
    final bloc = context.read<Bloc<dynamic, VideoPlayerState>>();
    bloc.add(VideoPauseEvent(pause: !bloc.state.isPaused));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Bloc<dynamic, VideoPlayerState>, VideoPlayerState>(
      buildWhen: (previous, current) => current.initialized,
      builder: (context, state) {
        final controller =
            (context.read<Bloc<dynamic, VideoPlayerState>>() as VideoPlayerBloc).controller;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => handleTapVideo(context),
          child: ColoredBox(
            color: Colors.black,
            child: Center(
              child: Stack(
                children: [
                  ValueListenableBuilder(
                    valueListenable: controller,
                    child: VideoPlayer(controller),
                    builder: (context, value, child) {
                      return AspectRatio(aspectRatio: controller.value.aspectRatio, child: child);
                    },
                  ),
                  Positioned.fill(
                    child: Center(child: PlayButton(isPause: !state.isPlaying && state.isPaused)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PlayButton extends StatefulWidget {
  const PlayButton({super.key, required this.isPause});

  final bool isPause;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 100),
  );

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    if (widget.isPause) {
      controller.forward(from: 0);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PlayButton oldWidget) {
    widget.isPause ? controller.forward(from: controller.value) : controller.value = 0.0;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacityOffStage(
      opacity: widget.isPause ? 0.3 : 0,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: (120 * (1 - controller.value)) + 110,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
