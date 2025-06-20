import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_tabs_view/home_tabs.dart';
import 'package:ui_kit/appbar_manager.dart';
import 'package:ui_kit/media_certificate/indexed_media_certificate.dart';

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
    required this.recommendedShorts,
    required this.friendShorts,
    required this.subscribedShorts,
    required this.onPressSearch,
  });

  final Widget mall;
  final Widget message;
  final Widget me;
  final Widget recommendedShorts;
  final Widget friendShorts;
  final Widget subscribedShorts;
  final FutureOr<void> Function() onPressCreate;
  final VoidCallback onPressSearch;

  @override
  State<MainTabsView> createState() => _MainTabsViewState();
}

class _MainTabsViewState<T extends StatefulWidget> extends State<MainTabsView> with AppBarManager {
  final ValueNotifier<int> index = ValueNotifier(0);
  double barHeight = 46.5;
  bool showBottomBar = true;

  @override
  void changeAppBar({bool? top, bool? bottom}) {
    if (bottom != null && bottom != showBottomBar) {
      setState(() {
        showBottomBar = bottom;
      });
    }
    super.changeAppBar(top: top, bottom: bottom);
  }

  void handleIndexChange(int index) => this.index.value = index;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    final EdgeInsets viewPadding = EdgeInsets.only(bottom: barHeight);
    media = media.copyWith(viewPadding: media.viewPadding.add(viewPadding) as EdgeInsets);

    final Widget home = IndexedMediaCertificateScope(
      index: 0,
      child: HomeView<T>(
        friendShorts: widget.friendShorts,
        recommendedShorts: widget.recommendedShorts,
        subscribedShorts: widget.subscribedShorts,
        onPressSearch: widget.onPressSearch,
      ),
    );

    final Widget bottom = ValueListenableBuilder(
      valueListenable: index,
      builder: (context, value, child) {
        return BottomBar(index: value, onIndexChange: handleIndexChange);
      },
    );
    final Widget stack = IndexedMediaCertificateDispatcher(
      controller: index,
      child: ValueListenableBuilder(
        valueListenable: index,
        builder: (context, value, child) {
          return IndexedStack(
            index: value,
            children: [
              IndexedMediaCertificateScope(index: 0, child: home),
              IndexedMediaCertificateScope(index: 1, child: widget.mall),
              IndexedMediaCertificateScope(index: 2, child: widget.message),
              IndexedMediaCertificateScope(index: 3, child: widget.me),
            ],
          );
        }
      ),
    );
    return Theme(
      data: Theme.of(context).copyWith(
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white)),
        ),
        buttonTheme: ButtonThemeData(buttonColor: Colors.white),
      ),
      child: ColoredBox(
        color: Colors.black,
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Offstage(offstage: orientation == Orientation.landscape, child: bottom),
                if (showBottomBar) MediaQuery(data: media, child: stack),
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
    final bool isHome = index == 0;
    final Color foregroundColor = isHome ? Colors.white : Colors.black;
    final Color unSelectedColor = foregroundColor.withAlpha(180);
    final Color backgroundColor = isHome ? Colors.black87 : Colors.white;
    final TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: SizedBox(
        height: 46,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(titles.length, (index) {
            final color = WidgetStatePropertyAll<Color>(
              this.index == index ? foregroundColor : unSelectedColor,
            );
            return Expanded(
              child: TextButton(
                onPressed: () => onIndexChange(index),
                style: ButtonStyle(
                  animationDuration: Duration.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: color,
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                  textStyle: WidgetStatePropertyAll(textStyle),
                ),
                child: Text(titles[index]),
              ),
            );
          }),
        ),
      ),
    );
  }
}
