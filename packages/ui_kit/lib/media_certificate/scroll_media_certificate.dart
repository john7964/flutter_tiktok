import 'dart:collection';

import 'package:flutter/material.dart';

import 'media_certificate.dart';

class ScrolledMediaCertificationDispatcher extends StatefulWidget {
  const ScrolledMediaCertificationDispatcher({super.key, required this.child});

  final Widget child;

  @override
  State<ScrolledMediaCertificationDispatcher> createState() =>
      _ScrolledMediaCertificationDispatcherState();
}

class _ScrolledMediaCertificationDispatcherState extends State<ScrolledMediaCertificationDispatcher>
    with MediaCertificationConsumer, MediaCertificationDispatcher {

  bool handleNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    markCertificateDirty();
    return false;
  }

  int? lastSeq;

  @override
  bool shouldIssueCertification(MediaCertificationConsumer consumer) {
    final RenderBox? scrollableRenderBox =
        Scrollable.of(consumer.context).context.findRenderObject() as RenderBox?;

    final RenderBox? childRenderBox = consumer.context.findRenderObject() as RenderBox?;

    final Offset? offset = childRenderBox?.localToGlobal(
      Offset.zero,
      ancestor: scrollableRenderBox,
    );
    bool isVisible =
        (offset?.dy ?? -1) >= 0 && (offset?.dy ?? -1) < (scrollableRenderBox?.size.height ?? 0.0);
    int seq =
        consumer.context.getInheritedWidgetOfExactType<ScrollableMediaCertificateScope>()!.sequence;
    if (isVisible && (lastSeq == null || seq <= lastSeq!)) {
      lastSeq = seq;
      return true;
    } else if (seq == lastSeq) {
      lastSeq = null;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: handleNotification,
      child: widget.child,
    );
  }
}

class ScrollableMediaCertificateScope extends InheritedWidget {
  const ScrollableMediaCertificateScope({super.key, required this.sequence, required super.child});

  final int sequence;

  @override
  bool updateShouldNotify(covariant ScrollableMediaCertificateScope oldWidget) =>
      oldWidget.sequence != sequence;
}
