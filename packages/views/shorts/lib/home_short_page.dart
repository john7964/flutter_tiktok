import 'package:flutter/material.dart';
import 'package:shorts_view/shorts_page/shorts_page.dart';


class HomeShortsPages extends StatefulWidget {
  const HomeShortsPages({super.key});

  @override
  State<HomeShortsPages> createState() => _HomeShortsPagesState();
}

class _HomeShortsPagesState extends State<HomeShortsPages> {
  @override
  Widget build(BuildContext context) {
    return ShortsPages();
  }
}

class RecommendedPages extends StatelessWidget {
  const RecommendedPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (pointer){

      },
      child: LayoutBuilder(builder: (context, constrains) {
        return Column(
          children: [
            Container(height: 200, color: Colors.white12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                child: OverflowBox(
                  maxHeight: constrains.maxHeight,
                  child: ShortsPages(),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
