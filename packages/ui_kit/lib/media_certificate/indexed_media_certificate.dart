import 'package:flutter/material.dart';
import 'media_certificate.dart';

class IndexedMediaCertificateDispatcher extends StatefulWidget {
  const IndexedMediaCertificateDispatcher({
    super.key,
    required this.child,
    required this.controller,
  });

  final ValueNotifier<int> controller;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _IndexedMediaCertificateDispatcherState();
}

class _IndexedMediaCertificateDispatcherState extends State<IndexedMediaCertificateDispatcher>
    with MediaCertificationConsumer, MediaCertificationDispatcher {
  ValueNotifier<int>? _tabController;

  ValueNotifier<int> get controller => _tabController!;

  @override
  bool shouldIssueCertification(MediaCertificationConsumer consumer) {
    final int index =
        consumer.context.dependOnInheritedWidgetOfExactType<IndexedMediaCertificateScope>()!.index;
    return index == controller.value;
  }

  @override
  void initState() {
    initController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant IndexedMediaCertificateDispatcher oldWidget) {
    initController();
    super.didUpdateWidget(oldWidget);
  }

  void initController() {
    ValueNotifier<int> tabController = widget.controller;
    if (_tabController == null || _tabController != tabController) {
      _tabController?.removeListener(markCertificateDirty);
      _tabController = tabController;
      _tabController!.addListener(markCertificateDirty);
      markCertificateDirty();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _tabController?.removeListener(markCertificateDirty);
    super.dispose();
  }
}

class IndexedMediaCertificateScope extends InheritedWidget {
  const IndexedMediaCertificateScope({super.key, required this.index, required super.child});

  final int index;

  @override
  bool updateShouldNotify(covariant IndexedMediaCertificateScope oldWidget) =>
      oldWidget.index != index;
}
