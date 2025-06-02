import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts_view/video_indicator.dart';
import 'package:ui_kit/animated_off_stage.dart';

import 'bloc/video_player_events.dart';
import 'bloc/video_player_state.dart';

const Duration _duration = Duration(milliseconds: 100);

class VideoForeground extends StatefulWidget {
  const VideoForeground({
    super.key,
    required this.onTapComments,
    required this.onTapText,
    required this.opacity,
  });

  final VoidCallback onTapComments;
  final VoidCallback onTapText;
  final double? opacity;

  @override
  State<VideoForeground> createState() => _VideoForegroundState();
}

class _VideoForegroundState extends State<VideoForeground> {
  void handleTapVideo() {
    final bloc = context.read<Bloc<dynamic, VideoPlayerState>>();
    bloc.add(VideoPauseEvent(pause: !bloc.state.isPaused));
  }

  void toggleFullScreen(Orientation orientation) {
    if (orientation == Orientation.portrait) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleTapVideo,
      child: AnimatedOpacity(
        duration: _duration,
        opacity: widget.opacity ?? 1.0,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: VideoLeftInfo(onTextTap: widget.onTapText)),
                    SizedBox(width: 32),
                    VideoRightBar(onTapComments: widget.onTapComments),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: BlocBuilder<Bloc<dynamic, VideoPlayerState>, VideoPlayerState>(
                  builder: (context, state) => VideoIndicator(playerState: state),
                ),
              ),
            ),
            Align(
              child: BlocBuilder<Bloc<dynamic, VideoPlayerState>, VideoPlayerState>(
                builder: (context, state) => PlayButton(isPause: state.isPaused),
              ),
            )
          ],
        ),
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
        style: TextStyle(color: Colors.white, fontSize: 14.5, height: 1.4),
        overflow: TextOverflow.ellipsis,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle(
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              maxLines: 1,
              child: Text("@Name and Last name"),
            ),
            SizedBox(height: 8.0),
            Text(
              "孝庄苏麻喇姑去世，索额图被关进大牢，康熙帝痛哭流涕，感叹：朕失去了一个母亲！",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
      data: IconThemeData(color: Colors.white.withAlpha(220), size: 34),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12),
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

class PlayButton extends StatefulWidget {
  const PlayButton({super.key, required this.isPause});

  final bool isPause;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(vsync: this, duration: _duration);

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
