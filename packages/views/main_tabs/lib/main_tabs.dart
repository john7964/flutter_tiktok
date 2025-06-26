import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_tabs_view/home_tabs.dart';
import 'package:provider/provider.dart';
import 'package:ui_kit/appbar_manager.dart';
import 'package:ui_kit/media_certificate/indexed_media_certificate.dart';
import 'package:view_integration/main_tabs_provider.dart';
import 'package:view_integration/message_provider.dart';
import 'package:view_integration/user_provider.dart';

const MainTabsDelegate mainTabsDelegate = MainTabsImpl();

class MainTabsImpl extends MainTabsDelegate {
  const MainTabsImpl();

  @override
  final Widget mainTabs = const MainTabsView();
}

class MainTabsView extends StatefulWidget {
  const MainTabsView({super.key});

  @override
  State<MainTabsView> createState() => _MainTabsViewState();
}

class _MainTabsViewState extends State<MainTabsView> with AppBarManager {
  final ValueNotifier<int> index = ValueNotifier(0);
  double barHeight = 70;
  ValueNotifier<bool> showBottomBar = ValueNotifier(true);

  @override
  void changeAppBar({bool? top, bool? bottom}) {
    if (bottom != null) {
      showBottomBar.value = bottom;
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
    media = media.copyWith(viewPadding: media.viewPadding.copyWith(bottom: barHeight));

    final Widget home = IndexedMediaCertificateScope(index: 0, child: const HomeView());
    final Widget userHome = context.read<UserDelegate>().userHome;
    final Widget bottom = ValueListenableBuilder(
      valueListenable: index,
      builder: (context, value, child) {
        return BottomBar(index: value, onIndexChange: handleIndexChange);
      },
    );
    final Widget message = context.read<MessageDelegate>().messageMain();
    final Widget stack = IndexedMediaCertificateDispatcher(
      controller: index,
      child: ValueListenableBuilder(
        valueListenable: index,
        builder: (context, value, child) {
          return IndexedStack(
            index: value,
            children: [
              IndexedMediaCertificateScope(index: 0, child: home),
              IndexedMediaCertificateScope(index: 1, child: userHome),
              IndexedMediaCertificateScope(index: 2, child: message),
              IndexedMediaCertificateScope(index: 3, child: userHome),
            ],
          );
        },
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
                MediaQuery(data: media, child: stack),
                ValueListenableBuilder(
                  valueListenable: showBottomBar,
                  builder: (context, value, child) {
                    return Offstage(offstage: !value, child: bottom);
                  },
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
    final bool isHome = index == 0;
    final Color foregroundColor = isHome ? Colors.white : Colors.black;
    final Color unSelectedColor = foregroundColor.withAlpha(180);
    final Color backgroundColor = isHome ? Color(0xFF181818) : Colors.white;
    final TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    final List<Widget> buttons = List.generate(titles.length, (index) {
      final color = WidgetStatePropertyAll<Color>(
        this.index == index ? foregroundColor : unSelectedColor,
      );
      return Expanded(
        child: TextButton(
          onPressed: () => onIndexChange(index),
          style: ButtonStyle(foregroundColor: color),
          child: Text(titles[index]),
        ),
      );
    }, growable: true);

    buttons.insert(
      2,
      Expanded(child: Center(child: IconButton(onPressed: () {}, icon: Icon(Icons.add_rounded)))),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(),
      child: Theme(
        data: ThemeData(
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              animationDuration: Duration.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              textStyle: WidgetStatePropertyAll(textStyle),
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              animationDuration: Duration.zero,
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6, vertical: 3)),
              foregroundColor: WidgetStatePropertyAll(foregroundColor),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: WidgetStatePropertyAll(BorderSide(color: foregroundColor, width: 2.5)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
              ),
              iconSize: WidgetStatePropertyAll(22.0),
              minimumSize: WidgetStatePropertyAll(Size(20, 20)),
            ),
          ),
        ),
        child: Container(
          color: backgroundColor,
          height: 70,
          padding: EdgeInsets.only(top: 4, bottom: 24),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: buttons),
        ),
      ),
    );
  }
}
