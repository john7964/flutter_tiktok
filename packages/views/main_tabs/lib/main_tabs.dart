import 'dart:async';

import 'package:flutter/material.dart';
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
  double barHeight = 40;

  void handleIndexChange(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final newData = mediaQueryData.copyWith(
      viewPadding: mediaQueryData.viewPadding.add(EdgeInsets.only(bottom: barHeight)) as EdgeInsets,
      padding: mediaQueryData.padding.add(EdgeInsets.only(bottom: barHeight)) as EdgeInsets,
    );

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
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          GestureDetector(
            onTapDown: (details) => print("onTapDown2: $details"),
            behavior: HitTestBehavior.translucent,
            child: BottomBar(index: index, onIndexChange: handleIndexChange),
          ),
          MediaQuery(
            data: newData,
            child: IndexedStack(
              index: index,
              children: [home, widget.mall, widget.message, widget.me],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.index, required this.onIndexChange});
  final int index;
  final void Function(int index) onIndexChange;

  @override
  Widget build(BuildContext context) {
    print(
      "MediaQuery.of(context).viewPadding.bottom: ${MediaQuery.of(context).viewPadding.bottom}",
    );

    print("MediaQuery.of(context).viewPadding.top: ${MediaQuery.of(context).viewPadding.top}");
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Expanded(child: TextButton(onPressed: () => onIndexChange(0), child: Text("1"))),
            Expanded(child: TextButton(onPressed: () => onIndexChange(1), child: Text("2"))),
            Expanded(child: TextButton(onPressed: () => onIndexChange(2), child: Text("3"))),
            Expanded(child: TextButton(onPressed: () => onIndexChange(3), child: Text("4"))),
          ],
        ),
      ),
    );
  }
}
