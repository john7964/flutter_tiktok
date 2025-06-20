import 'package:flutter/cupertino.dart';
import 'package:shorts_view/shorts_page/shorts_page.dart';

class HomeShortsPage extends StatefulWidget {
  const HomeShortsPage({super.key});

  @override
  State<HomeShortsPage> createState() => _HomeShortsPageState();
}

class _HomeShortsPageState extends State<HomeShortsPage> {
  @override
  Widget build(BuildContext context) {
    return ShortsPage();
  }
}
