import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main_tabs_view/scaffold.dart';
import 'package:ui_kit/animated_off_stage.dart';
import 'package:ui_kit/media.dart';
import 'package:ui_kit/tabs.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class HomeView<T extends StatefulWidget> extends StatefulWidget {
  const HomeView({
    super.key,
    required this.showTabBar,
    required this.recommendedShorts,
    required this.friendShorts,
    required this.subscribedShorts,
  });

  final bool showTabBar;
  final Widget recommendedShorts;
  final Widget friendShorts;
  final Widget subscribedShorts;

  @override
  State<HomeView<T>> createState() => HomeViewState<T>();
}

class HomeViewState<T extends StatefulWidget> extends State<HomeView<T>>
    with SingleTickerProviderStateMixin {
  late final TabController2 controller = TabController2(length: 3, vsync: this)..index = 2;

  @override
  void initState() {
    controller.addIndexListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar = AppBar(
      toolbarHeight: 44,
      forceMaterialTransparency: true,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: Icon(CupertinoIcons.search, size: 26, color: Colors.white.withAlpha(230)),
          onPressed: () {},
        ),
      ],
      title: TabBar(
        controller: controller,
        labelColor: Colors.white.withAlpha(230),
        unselectedLabelColor: Colors.white.withAlpha(180),
        tabAlignment: TabAlignment.center,
        dividerHeight: 0.0,
        indicatorWeight: 2,
        indicatorColor: Colors.white,
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        tabs: [Text("关注"), Text("朋友"), Text("推荐")],
      ),
    );

    return TransparencyScaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      drawer: SizedBox(width: 300),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          TabBarView2(
            controller: controller,
            children: [
              PreventMedia(
                prevent: controller.index != 0 || PreventMedia.of(context),
                child: KeepAliveShorts(child: widget.subscribedShorts),
              ),
              PreventMedia(
                prevent: controller.index != 1 || PreventMedia.of(context),
                child: KeepAliveShorts(child: widget.friendShorts),
              ),
              PreventMedia(
                prevent: controller.index != 2 || PreventMedia.of(context),
                child: KeepAliveShorts(child: widget.recommendedShorts),
              ),
            ],
          ),
          AnimatedOpacityOffStage(
            opacity:
                widget.showTabBar && MediaQuery.orientationOf(context) == Orientation.portrait
                    ? 1.0
                    : 0.0,
            child: appBar,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class KeepAliveShorts extends StatefulWidget {
  const KeepAliveShorts({super.key, required this.child});

  final Widget child;

  @override
  State<KeepAliveShorts> createState() => _KeepAliveShortsState();
}

class _KeepAliveShortsState extends State<KeepAliveShorts>
    with AutomaticKeepAliveClientMixin<KeepAliveShorts> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
