import 'package:flutter/material.dart';

class DraggableScrollableRoute<T> extends ModalRoute<T> {
  DraggableScrollableRoute({
    super.settings,
    super.requestFocus,
    super.filter,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
    this.onDispose,
    required this.builder,
  });

  static DraggableScrollableRouteScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DraggableScrollableRouteScope>()!;
  }

  final WidgetBuilder builder;

  final VoidCallback? onDispose;

  @override
  Color? get barrierColor => Colors.black12;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  bool get opaque => false;

  late final DraggableScrollableRouteController draggableScrollableController;

  @override
  void install() {
    super.install();
    draggableScrollableController = DraggableScrollableRouteController(routeAnimation: controller!);
    draggableScrollableController._initRouteAnimation();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return DraggableScrollableRouteScope(
      controller: draggableScrollableController,
      child: builder(context),
    );
  }

  @override
  void dispose() {
    onDispose?.call();
    draggableScrollableController.dispose();
    super.dispose();
  }
}

class DraggableScrollableRouteScope extends InheritedWidget {
  final DraggableScrollableController controller;

  const DraggableScrollableRouteScope({super.key, required super.child, required this.controller});

  @override
  bool updateShouldNotify(covariant DraggableScrollableRouteScope oldWidget) {
    return oldWidget.controller != controller;
  }
}

class DraggableScrollableRouteController extends DraggableScrollableController {
  final Animation<double> routeAnimation;
  late final CurvedAnimation curvedAnimation;

  DraggableScrollableRouteController({required this.routeAnimation});

  void _initRouteAnimation() {
    curvedAnimation = CurvedAnimation(
      curve: Curves.fastEaseInToSlowEaseOut,
      parent: routeAnimation,
    );

    curvedAnimation.addListener(() {
      if (isAttached) {
        jumpTo(routeAnimation.value * 0.7);
      }
    });
  }
}
