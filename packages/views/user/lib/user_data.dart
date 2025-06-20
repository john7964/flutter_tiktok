import 'dart:ui';

import 'package:flutter/material.dart';

class UserData extends StatelessWidget {
  const UserData({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      children: [
        DataItem(data: "19", label: "获赞"),
        DataItem(data: "9", label: "互关"),
        DataItem(data: "575", label: "关注"),
        DataItem(data: "30", label: "粉丝"),
      ],
    );
  }
}

class DataItem extends StatelessWidget {
  const DataItem({super.key, required this.data, required this.label});

  final String data;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DefaultTextStyle(
          style: TextTheme.of(context).titleSmall!.copyWith(fontWeight: FontWeight.w700),
          child: Text(data),
        ),
        DefaultTextStyle(style: Theme.of(context).textTheme.bodySmall!, child: Text(label)),
      ],
    );
  }
}

class UserIntroduce extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Flutter全链条持续更新中..."),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 12, color: Colors.black38),
            child: Text("添加年龄，所在地标签"),
          ),
        ),
      ],
    );
  }
}

class UserFeatures extends StatelessWidget {
  const UserFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextTheme.of(context).bodySmall!,
      child: IconTheme(
        data: IconThemeData(color: Colors.black.withAlpha(150)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [Icon(Icons.shopping_bag_outlined), Text("电商带货")]),
            Column(children: [Icon(Icons.shopping_bag_outlined), Text("主播中心")]),
            Column(children: [Icon(Icons.shopping_bag_outlined), Text("抖音商城")]),
            Column(children: [Icon(Icons.shopping_bag_outlined), Text("观看历史")]),
            Column(children: [Icon(Icons.shopping_bag_outlined), Text("全部功能")]),
          ],
        ),
      ),
    );
  }
}

class UserTitle extends StatelessWidget {
  const UserTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.viewPaddingOf(context).top;
    final double topHeight = topPadding + 32 + 18;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double currentHeight = clampDouble(constraints.maxHeight, topHeight, topHeight * 2);
        final double scale = (currentHeight - topHeight) / topHeight;

        final Widget top = Container(
          height: topHeight,
          color: Colors.white.withAlpha((255 * (1 - scale)).toInt()),
          padding: EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                Offstage(
                  offstage: scale == 1.0,
                  child: Opacity(
                    opacity: 1 - scale,
                    child: DefaultTextStyle(
                      style: TextTheme.of(context).titleMedium!,
                      child: Text("小明小透明"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return top;
      },
    );
  }
}
