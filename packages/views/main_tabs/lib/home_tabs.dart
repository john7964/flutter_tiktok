import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/animated_off_stage.dart';
import 'package:ui_kit/appbar_manager.dart';
import 'package:ui_kit/tabs.dart';
import 'package:ui_kit/media_certificate/indexed_media_certificate.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class HomeView<T extends StatefulWidget> extends StatefulWidget {
  const HomeView({
    super.key,
    required this.recommendedShorts,
    required this.friendShorts,
    required this.subscribedShorts,
    required this.onPressSearch,
  });

  final Widget recommendedShorts;
  final Widget friendShorts;
  final Widget subscribedShorts;
  final VoidCallback onPressSearch;

  @override
  State<HomeView<T>> createState() => HomeViewState<T>();
}

class HomeViewState<T extends StatefulWidget> extends State<HomeView<T>>
    with SingleTickerProviderStateMixin, AppBarManager {
  late final TabController2 controller = TabController2(length: 3, vsync: this, initialIndex: 2);
  ValueNotifier<int> index = ValueNotifier(2);
  bool showTopBar = true;

  @override
  void changeAppBar({bool? top, bool? bottom}) {
    if (top != null && showTopBar != top) {
      setState(() => showTopBar = top);
    }
    super.changeAppBar(top: top, bottom: bottom);
  }

  void handleTabChanged() {
    if (controller.index != index.value) {
      this.index.value = controller.index;
    }
  }

  @override
  void initState() {
    controller.addListener(handleTabChanged);
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
          onPressed: widget.onPressSearch,
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
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        tabs: [Text("关注"), Text("朋友"), Text("推荐")],
      ),
    );

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        IndexedMediaCertificateDispatcher(
          controller: index,
          child: TabBarView2(
            controller: controller,
            children: [
              IndexedMediaCertificateScope(
                index: 0,
                child: KeepAliveShorts(child: widget.subscribedShorts),
              ),
              IndexedMediaCertificateScope(
                index: 1,
                child: KeepAliveShorts(child: widget.friendShorts),
              ),
              IndexedMediaCertificateScope(
                index: 2,
                child: KeepAliveShorts(child: widget.recommendedShorts),
              ),
            ],
          ),
        ),
        AnimatedOpacityOffStage(
          opacity:
              showTopBar && MediaQuery.orientationOf(context) == Orientation.portrait ? 1.0 : 0.0,
          child: appBar,
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    index.dispose();
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
