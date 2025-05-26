import 'package:flutter/material.dart';
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
  int index = 2;
  late final TabController controller = TabController(length: 3, vsync: this)..index = index;

  @override
  void initState() {
    controller.addListener(() {
      setState(() => index = controller.index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final newData = mediaQueryData.copyWith(
      viewPadding: mediaQueryData.viewPadding.add(EdgeInsets.only(top: 40)) as EdgeInsets,
    );

    return Stack(
      children: [
        MediaQuery(
          data: newData,
          child: TabBarView2(
            controller: controller,
            children: [
              PreventMedia(
                prevent: index != 0 || PreventMedia.of(context),
                child: KeepAliveShorts(child: widget.subscribedShorts),
              ),
              PreventMedia(
                prevent: index != 1 || PreventMedia.of(context),
                child: KeepAliveShorts(child: widget.friendShorts),
              ),
              PreventMedia(
                prevent: index != 2 || PreventMedia.of(context),
                child: KeepAliveShorts(child: widget.recommendedShorts),
              ),
            ],
          ),
        ),
        Material(
          type: MaterialType.transparency,
          color: Colors.black,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 40,
              child: TabBar(controller: controller, tabs: [Text("1"), Text("2"), Text("3")]),
            ),
          ),
        ),
      ],
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
