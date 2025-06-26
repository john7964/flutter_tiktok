import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/theme/theme.dart';
import 'package:user/user_header/user_header_scaffold.dart';
import 'package:view_integration/user_provider.dart';

import 'nest_scroll_view/nested_scroll_view.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

const UserDelegate userDelegate = UserDelegateImpl();

class UserDelegateImpl extends UserDelegate {
  const UserDelegateImpl();

  @override
  final Widget userHome = const UserHome();
}

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final PageStorageKey pageStorageKey = PageStorageKey("1");

  @override
  Widget build(BuildContext context) {
    Widget child = DefaultTabController(
      length: 5,
      child: NestedScrollViewPlus(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        headerSliverBuilder: (context, scrolled) => [SliverUserHeader()],
        body: Builder(
          builder: (context) {
            return TabBarView(
              children: [
                CustomScrollView(
                  key: pageStorageKey,
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 4,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return OpenContainer(
                          openColor: Colors.transparent,
                          closedColor: Colors.transparent,
                          closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          closedBuilder: (context, fn) {
                            return LayoutBuilder(
                              builder: (context, constrains) {
                                return Container(
                                  color: Colors.blue,
                                  alignment: Alignment.center,
                                  child: Text("$index"),
                                );
                              },
                            );
                          },
                          openBuilder: (context, action) {
                            return Scaffold(
                              appBar: AppBar(),
                              body: Container(
                                color: Colors.amber,
                                alignment: Alignment.center,
                                child: Text("$index"),
                              ),
                            );
                          },
                        );
                      }, childCount: 100),
                    ),
                  ],
                ),
                CustomScrollView(
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    PinnedHeaderSliver(child: Container(color: Colors.green, child: Text("2"))),
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 4,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Container(
                          color: Colors.blue,
                          alignment: Alignment.center,
                          child: Text("$index"),
                        );
                      }, childCount: 100),
                    ),
                  ],
                ),
                CustomScrollView(
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverAppBar(title: Text("2"), pinned: true),
                    SliverToBoxAdapter(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                        child: Container(height: 200, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                CustomScrollView(
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverAppBar(title: Text("2"), pinned: true),
                    SliverToBoxAdapter(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                        child: Container(height: 200, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                CustomScrollView(
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverAppBar(title: Text("2"), pinned: true),
                    SliverToBoxAdapter(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                        child: Container(height: 200, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );

    return Theme(
      data: lightTheme,
      child: Material(color: Colors.white, child: child),
    );
  }
}
