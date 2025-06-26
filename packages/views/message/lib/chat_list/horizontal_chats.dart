import 'package:flutter/material.dart';

class HorizontalChats extends StatelessWidget {
  const HorizontalChats({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(10, (index) {
          return HorizontalChatItem();
        }),
      ),
    );
  }
}

class HorizontalChatItem extends StatelessWidget {
  const HorizontalChatItem({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextTheme.of(context).bodySmall!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(28)),
              child: Container(height: 56, width: 56, color: Colors.green),
            ),
            SizedBox(height: 8.0),
            SizedBox(width: 56, child: Text("谢老大")),
          ],
        ),
      ),
    );
  }
}
