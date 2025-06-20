import 'package:flutter/material.dart';
import 'package:ui_kit/media_certificate/media_certificate.dart';

class CertificateDispatchNavigatorObserver extends NavigatorObserver with ChangeNotifier {
  Route? currentRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRoute = route;
    print(currentRoute);
    notifyListeners();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute = previousRoute;
    print(currentRoute);
    notifyListeners();
  }
}

class NavigatorMediaCertificateDispatcher extends StatefulWidget {
  const NavigatorMediaCertificateDispatcher({
    super.key,
    required this.observer,
    required this.child,
  });

  final CertificateDispatchNavigatorObserver observer;
  final Widget child;

  @override
  State<NavigatorMediaCertificateDispatcher> createState() =>
      _NavigatorMediaCertificateDispatcherState();
}

class _NavigatorMediaCertificateDispatcherState extends State<NavigatorMediaCertificateDispatcher>
    with MediaCertificationConsumer, MediaCertificationDispatcher {
  CertificateDispatchNavigatorObserver? _observer;
  CertificateDispatchNavigatorObserver get observer => _observer!;

  void _initObserver() {
    if (_observer == null || _observer != widget.observer) {
      _observer?.removeListener(markCertificateDirty);
      _observer = widget.observer;
      _observer!.addListener(markCertificateDirty);
      markCertificateDirty();
    }
  }

  @override
  void markCertificateDirty() {
    super.markCertificateDirty();
  }

  @override
  bool shouldIssueCertification(MediaCertificationConsumer<StatefulWidget> consumer) {
    final route =
        consumer.context
            .dependOnInheritedWidgetOfExactType<NavigatorMediaCertificateScope>()!
            .route;
    final bool res =  route == observer.currentRoute;
    return res;
  }

  @override
  void initState() {
    _initObserver();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant NavigatorMediaCertificateDispatcher oldWidget) {
    _initObserver();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    widget.observer.removeListener(markCertificateDirty);
    super.dispose();
  }

}

class NavigatorMediaCertificateScope extends InheritedWidget {
  const NavigatorMediaCertificateScope({super.key, required super.child, required this.route});

  final ModalRoute route;

  @override
  bool updateShouldNotify(covariant NavigatorMediaCertificateScope oldWidget) {
    return oldWidget.route != route;
  }
}
