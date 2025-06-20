import 'package:flutter/widgets.dart';
import 'package:shorts_view/home_short_page.dart';

class ShortsIntegration extends StatefulWidget {
  const ShortsIntegration({super.key});

  @override
  State<ShortsIntegration> createState() => _ShortsIntegrationState();
}

class _ShortsIntegrationState extends State<ShortsIntegration> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return HomeShortsPage();
  }
}
