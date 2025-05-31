import 'package:flutter/widgets.dart';
import 'package:shorts_view/video.dart';
import 'package:ui_kit/media.dart';
import 'package:ui_kit/root_navigator.dart';

class ShortsIntegration extends StatefulWidget {
  const ShortsIntegration({super.key, required this.onRequestShowBar});

  final void Function({bool top, bool bottom}) onRequestShowBar;

  @override
  State<ShortsIntegration> createState() => _ShortsIntegrationState();
}

class _ShortsIntegrationState extends State<ShortsIntegration> with RouteAware {
  bool preventMedia = false;

  @override
  void didChangeDependencies() {
    RootNavigator.of(context).subscribeRouteAware(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void didPush() {
    if (preventMedia) {
      setState(() => preventMedia = false);
    }
    super.didPush();
  }

  @override
  void didPop() {
    if (!preventMedia) {
      setState(() => preventMedia = true);
    }
  }

  @override
  void didPushNext() {
    if (!preventMedia) {
      setState(() => preventMedia = true);
    }
    super.didPushNext();
  }

  @override
  void didPopNext() {
    if (preventMedia) {
      setState(() => preventMedia = false);
    }
    super.didPushNext();
  }

  @override
  Widget build(BuildContext context) {
    return PreventMedia(
      prevent: preventMedia || PreventMedia.of(context),
      child: Shorts(onRequestShowBar: widget.onRequestShowBar),
    );
  }

  @override
  void dispose() {
    RootNavigator.of(context).unSubscribeRouteAware(this);
    super.dispose();
  }
}
