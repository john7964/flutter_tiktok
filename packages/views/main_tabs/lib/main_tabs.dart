import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_tabs_view/home_tabs.dart';
import 'package:ui_kit/media.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class MainTabsView extends StatefulWidget {
  const MainTabsView({
    super.key,
    required this.mall,
    required this.message,
    required this.me,
    required this.onPressCreate,
    required this.showBottomBar,
    required this.showTopBar,
    required this.recommendedShorts,
    required this.friendShorts,
    required this.subscribedShorts,
  });

  final bool showTopBar;
  final bool showBottomBar;
  final Widget mall;
  final Widget message;
  final Widget me;
  final Widget recommendedShorts;
  final Widget friendShorts;
  final Widget subscribedShorts;
  final FutureOr<void> Function(BuildContext context) onPressCreate;

  @override
  State<MainTabsView> createState() => _MainTabsViewState();
}

class _MainTabsViewState<T extends StatefulWidget> extends State<MainTabsView> {
  int index = 0;
  double barHeight = 46;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white));
    super.initState();
  }

  void handleIndexChange(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home = PreventMedia(
      prevent: index != 0 || PreventMedia.of(context),
      child: HomeView<T>(
        showTabBar: widget.showTopBar,
        friendShorts: widget.friendShorts,
        recommendedShorts: widget.recommendedShorts,
        subscribedShorts: widget.subscribedShorts,
      ),
    );

    return Theme(
      data: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white)),
        ),
        buttonTheme: ButtonThemeData(buttonColor: Colors.white),
      ),
      child: ColoredBox(
        color: Colors.black,
        child: OrientationBuilder(
          builder: (context, orientation) {
            MediaQueryData media = MediaQuery.of(context);
            if (orientation == Orientation.portrait) {
              media = media.copyWith(
                padding: media.padding.add(EdgeInsets.only(bottom: barHeight)) as EdgeInsets,
              );
            }
            return Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Offstage(
                  offstage: orientation == Orientation.landscape,
                  child: BottomBar(index: index, onIndexChange: handleIndexChange),
                ),
                MediaQuery(
                  data: media,
                  child: IndexedStack(
                    index: index,
                    children: [
                      home,
                      SafeArea(top: false, child: widget.mall),
                      SafeArea(top: false, child: widget.message),
                      SafeArea(top: false, child: widget.me),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.index, required this.onIndexChange});

  final int index;
  final void Function(int index) onIndexChange;
  final List<String> titles = const ["首页", "朋友", "消息", "我"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
      child: SizedBox(
        height: 46,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(titles.length, (index) {
            final foregroundColor = WidgetStatePropertyAll<Color>(
              this.index == index ? Colors.white : Colors.white.withAlpha(180),
            );
            return Expanded(
              child: LayoutBuilder(
                builder: (context, constrains) {
                  print(constrains);
                  return TextButton(
                    onPressed: () => onIndexChange(index),
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: foregroundColor,
                      textStyle: WidgetStatePropertyAll(
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    child: Text(titles[index]),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
