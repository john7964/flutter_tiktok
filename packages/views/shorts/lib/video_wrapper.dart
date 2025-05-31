import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts_view/bloc/video_player_events.dart';
import 'package:ui_kit/media.dart';
import 'package:video_player/video_player.dart';

import 'bloc/video_player_state.dart';

class VideoAspectRatio extends StatefulWidget {
  const VideoAspectRatio({super.key, required this.tween, required this.scale});

  final Tween<Size> tween;
  final double scale;

  @override
  State<VideoAspectRatio> createState() => _VideoAspectRatioState();
}

class _VideoAspectRatioState extends State<VideoAspectRatio> {
  Size _applyAspectRatio(BoxConstraints constraints, double aspectRatio) {
    if (constraints.isTight) {
      return constraints.smallest;
    }

    double width = constraints.maxWidth;
    double height;

    if (width.isFinite) {
      height = width / aspectRatio;
    } else {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width > constraints.maxWidth) {
      width = constraints.maxWidth;
      height = width / aspectRatio;
    }

    if (height > constraints.maxHeight) {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width < constraints.minWidth) {
      width = constraints.minWidth;
      height = width / aspectRatio;
    }

    if (height < constraints.minHeight) {
      height = constraints.minHeight;
      width = height * aspectRatio;
    }

    return constraints.constrain(Size(width, height));
  }

  BoxConstraints get beginConstraints => BoxConstraints(
        maxHeight: widget.tween.begin!.height,
        maxWidth: widget.tween.begin!.width,
      );

  BoxConstraints get endConstraints => BoxConstraints(
        maxHeight: widget.tween.end!.height,
        maxWidth: widget.tween.end!.width,
      );

  @override
  void didChangeDependencies() {
    final bool prevent = PreventMedia.of(context);
    context.read<Bloc<dynamic, VideoPlayerState>>().add(PreventMediaUpdatedEvent(prevent: prevent));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Bloc<dynamic, VideoPlayerState>, VideoPlayerState>(
      buildWhen: (previous, current) => current.initialized,
      builder: (context, state) {
        if (!state.initialized) {
          return Center(child: CircularProgressIndicator());
        }

        final double aspectRatio = state.aspectRatio!;
        final player = AspectRatio(aspectRatio: aspectRatio, child: VideoPlayer(state.controller));
        final Size beginSize = _applyAspectRatio(beginConstraints, aspectRatio);
        final Size endSize = _applyAspectRatio(endConstraints, aspectRatio);
        final Size? size = Size.lerp(beginSize, endSize, widget.scale);
        return LayoutBuilder(builder: (context, constraints) {
          return ColoredBox(
            color: Colors.white12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: size!.height,
                    maxWidth: size.width,
                  ).enforce(constraints),
                  child: player,
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

// Expanded(
//   child: UnconstrainedBox(
//     alignment: Alignment.topCenter,
//     child: OutlinedButton(
//       style: ButtonStyle(
//         shape: WidgetStatePropertyAll(
//           RoundedRectangleBorder(
//             side: BorderSide(color: Colors.amber, width: 5),
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//         iconColor: WidgetStatePropertyAll(Colors.white),
//         iconSize: WidgetStatePropertyAll(24),
//         padding: WidgetStatePropertyAll(
//           EdgeInsets.only(left: 6, right: 10, top: 2, bottom: 2),
//         ),
//         minimumSize: WidgetStatePropertyAll(Size(20, 20)),
//         maximumSize: WidgetStatePropertyAll(Size(200, 200)),
//         textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
//         foregroundColor: WidgetStatePropertyAll(Colors.white),
//       ),
//       onPressed: () => toggleFullScreen(orientation),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [Icon(Icons.fullscreen), Text("全屏观看")],
//       ),
//     ),
//   ),
// )
