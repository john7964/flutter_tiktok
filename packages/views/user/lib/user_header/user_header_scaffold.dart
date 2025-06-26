import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:user/sliver_overlap.dart';
import '../user_data.dart';
import 'package:ui_kit/custom_layout.dart';

class SliverUserHeader extends StatelessWidget {
  const SliverUserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverResizingOverlayHeader(
      maxExtentPrototype: UserHeaderScaffold(maxExtent: true),
      minExtentPrototype: UserHeaderScaffold(minExtent: true),
      child: UserHeaderScaffold(),
    );
  }
}

class UserHeaderScaffold extends StatelessWidget {
  const UserHeaderScaffold({super.key, this.maxExtent = false, this.minExtent = false});

  final bool maxExtent;
  final bool minExtent;

  @override
  Widget build(BuildContext context) {
    final Widget maxExtentBackground = SizedBoxBuilder.forSize(
      sizeBuilder: (constrains, size) => Size(size.width, size.height - 8),
      child: UserHeaderBackground(),
    );

    final Widget background = SizedBoxBuilder.forChildConstrains(
      constrainsBuilder: (constrains) => constrains.copyWith(maxHeight: constrains.maxHeight + 8),
      child: UserHeaderBackground(),
    );

    final Widget userInfo = ClipRRect(
      child: OverflowBox(
        fit: OverflowBoxFit.deferToChild,
        alignment: Alignment.bottomCenter,
        maxHeight: double.infinity,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserData(),
                  Spacer(),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black.withAlpha(16)),
                      foregroundColor: WidgetStatePropertyAll(Colors.black87),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      ),
                      minimumSize: WidgetStatePropertyAll(Size(20, 32)),
                    ),
                    onPressed: () {},
                    child: Text("编辑主页"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              UserIntroduce(),
              const SizedBox(height: 24),
              UserFeatures(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    final Widget flexibleSpace = LayoutBuilder(
      builder: (context, constrains) {
        final BoxConstraints constraints = BoxConstraints(maxHeight: constrains.maxHeight);
        final Widget body = ConstrainedBox(constraints: constraints, child: userInfo);
        return Stack(
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: [Flexible(child: background), body]),
            UserTitle(),
          ],
        );
      },
    );

    final Widget tabBar = TabBarTheme(
      data: TabBarThemeData(
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.black54,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0.1,
        indicatorColor: Colors.black87,
        labelStyle: TextTheme.of(context).titleSmall,
        unselectedLabelStyle: TextTheme.of(context).titleSmall,
        labelPadding: EdgeInsets.symmetric(vertical: 8),
      ),
      child: TabBar(tabs: [Text("作品"), Text("日常"), Text("推荐"), Text("收藏"), Text("喜欢")]),
    );

    if (minExtent) {
      return Column(children: [UserTitle(), tabBar]);
    } else if (maxExtent) {
      return Column(children: [maxExtentBackground, userInfo, tabBar]);
    } else {
      return Column(children: [Flexible(child: flexibleSpace), tabBar]);
    }
  }
}

class UserHeaderBackground extends StatefulWidget {
  const UserHeaderBackground({super.key});

  @override
  State<StatefulWidget> createState() => UserHeaderBackgroundState();
}

class UserHeaderBackgroundState extends State<UserHeaderBackground> {
  final AssetImage assetImage = AssetImage("assets/bg2.jpg", package: "user");

  @override
  Widget build(BuildContext context) {
    double imageAspectRatio = 16 / 10;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double originHeight = constraints.maxWidth / imageAspectRatio;
        final bool isInfinite = constraints.maxHeight.isInfinite;
        final Widget container = Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            image: DecorationImage(image: assetImage, fit: BoxFit.fitHeight),
          ),
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset("assets/bg1.jpg", package: "user", fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        );

        if (isInfinite) {
          return SizedBox(height: originHeight, child: container);
        } else {
          return OverflowBox(
            alignment: Alignment.bottomCenter,
            maxHeight: max(constraints.maxHeight, originHeight),
            child: container,
          );
        }
      },
    );
  }
}
