import 'package:flutter/material.dart';

class MediaCertificationVerify extends ValueNotifier<bool> {
  MediaCertificationVerify() : super(false);

  final Set<MediaCertificationConsumer> _consumers = {};

  bool addConsumer(MediaCertificationConsumer consumer) {
    final bool res = _consumers.add(consumer);
    consumer._updateVerify(this);
    return res;
  }

  void _update() {
    value = _consumers.any((consumer) => MediaCertificationDispatcher._of(consumer));
  }
}

mixin MediaCertificationConsumer<T extends StatefulWidget> on State<T> {
  MediaCertificationVerify? _verify;

  void _updateVerify(MediaCertificationVerify verify){
    if(_verify == verify){
      return;
    }
    _verify?._consumers.remove(this);
    _verify?._update();
    _verify = verify;
    _verify?._update();
  }

  @mustCallSuper
  void markCertificateDirty() {
    _verify?._update();
  }

  @override
  void dispose() {
    _verify?._consumers.remove(this);
    _verify?._update();
    super.dispose();
  }
}

mixin MediaCertificationDispatcher<T extends StatefulWidget> on MediaCertificationConsumer<T> {
  static bool _of(MediaCertificationConsumer consumer) {
    final BuildContext context = consumer.context;
    return context.findAncestorStateOfType<MediaCertificationDispatcher>()?._requestCertificate(
          consumer,
        ) ??
        true;
  }

  final Set<MediaCertificationConsumer> _consumers = {};

  bool _requestCertificate(MediaCertificationConsumer consumer) {
    _consumers.add(consumer);
    return shouldIssueCertification(consumer) && MediaCertificationDispatcher._of(this);
  }

  @override
  void markCertificateDirty() {
    for (var consumer in _consumers) {
      consumer.markCertificateDirty();
    }
    super.markCertificateDirty();
  }

  bool shouldIssueCertification(MediaCertificationConsumer consumer);

}
