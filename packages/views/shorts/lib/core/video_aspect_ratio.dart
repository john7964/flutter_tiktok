import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorts_view/bloc/video_player_bloc.dart';
import 'package:ui_kit/media_certificate/media_certificate.dart';
import 'package:video_player/video_player.dart';


class VideoAspectRatio extends StatefulWidget {
  const VideoAspectRatio({
    super.key,
    this.beginConstrains,
    this.endEndConstrains,
    this.paddingTween,
    this.padding,
  });

  final BoxConstraints? beginConstrains;
  final BoxConstraints? endEndConstrains;
  final EdgeInsetsTween? paddingTween;
  final EdgeInsets? padding;

  @override
  State<VideoAspectRatio> createState() => _VideoAspectRatioState();
}

class _VideoAspectRatioState extends State<VideoAspectRatio> with MediaCertificationConsumer{
  Size _applyAspectRatio(BoxConstraints constraints, double aspectRatio) {
    if (constraints.isTight) {
      return constraints.smallest;
    }

    if (constraints.maxHeight.isFinite && constraints.maxWidth.isFinite) {
      final double originAspectRatio = constraints.maxWidth / constraints.maxHeight;
      if ((originAspectRatio - aspectRatio).abs() < 0.1) {
        return constraints.biggest;
      }
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

  @override
  void didChangeDependencies() {
    context.read<ShortBloc>().add(
          UpdateCertificationConsumer(consumer: this),
        );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShortBloc, VideoPlayerState>(
      buildWhen: (previous, current) {
        return current.initialized && previous.aspectRatio != current.aspectRatio;
      },
      builder: (context, state) {
        if (!state.initialized) {
          return Center(child: CircularProgressIndicator());
        }
        final double aspectRatio = state.aspectRatio!;
        return OverflowBox(
          minWidth: 0.0,
          fit: OverflowBoxFit.deferToChild,
          child: LayoutBuilder(builder: (context, constraints) {
            final BoxConstraints fixedConstraints = constraints.loosen();
            final BoxConstraints beginConstraints = widget.beginConstrains ?? fixedConstraints;
            final BoxConstraints endConstraints = widget.endEndConstrains ?? fixedConstraints;
            final Size beginSize = _applyAspectRatio(
              beginConstraints.deflate(widget.paddingTween?.begin ?? EdgeInsets.zero),
              aspectRatio,
            );
            final Size endSize = _applyAspectRatio(
              endConstraints.deflate(widget.paddingTween?.end ?? EdgeInsets.zero),
              aspectRatio,
            );
            final double maxHeight = beginConstraints.maxHeight;
            final double minHeight = endConstraints.maxHeight;
            final double maxOffset = maxHeight - minHeight;
            final double offset = maxHeight - constraints.maxHeight;
            final double? fraction = maxOffset == 0 ? null : min(1.0, offset / maxOffset);
            final Size size =
                fraction == null ? beginSize : Size.lerp(beginSize, endSize, fraction)!;
            return Padding(
              padding:
                  widget.padding ?? widget.paddingTween?.lerp(fraction ?? 0.0) ?? EdgeInsets.zero,
              child: ColoredBox(
                color: Colors.white12,
                child: ClipRRect(
                  child: OverflowBox(
                    fit: OverflowBoxFit.deferToChild,
                    maxHeight:
                        size.width / aspectRatio > size.height ? double.infinity : size.height,
                    maxWidth: size.height * aspectRatio > size.width ? double.infinity : size.width,
                    minHeight: size.height,
                    minWidth: size.width,
                    child:
                        AspectRatio(aspectRatio: aspectRatio, child: VideoPlayer(state.controller)),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
