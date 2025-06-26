import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ui_kit/draggable.dart';

mixin ResizedRouteTarget<T extends StatefulWidget> on State<T> {
  @mustCallSuper
  void didUpdateFraction(double fraction) {
    if(fraction == 1.0){
      Scrollable.ensureVisible(context, alignment: 0.5);
    }
  }

  void didStartFraction() {}

  void didEndFraction() {}

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class DraggableResizedRoute<T> extends PageRoute<T> {
  DraggableResizedRoute({
    super.settings,
    super.requestFocus,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.barrierDismissible,
    required this.getTarget,
    required this.builder,
  });

  static ResizingRouteScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResizingRouteScope>();
  }

  final Widget Function(BuildContext context) builder;
  final ResizedRouteTarget Function() getTarget;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  ResizedRouteTarget? previousTarget;

  void handleFractionChanged() {
    final ResizedRouteTarget currentTarget = getTarget();
    if (previousTarget?._disposed ?? false) {
      previousTarget = null;
    }
    if (previousTarget != currentTarget) {
      previousTarget?.didUpdateFraction(0.0);
      previousTarget?.didEndFraction();
      previousTarget = currentTarget;
      currentTarget.didStartFraction();
    }
    currentTarget.didUpdateFraction(animation!.value);
  }

  @override
  void install() {
    super.install();
    controller!.addListener(handleFractionChanged);
  }

  @override
  void dispose() {
    previousTarget?.didEndFraction();
    super.dispose();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return ResizingRouteScope(animation: animation, child: builder(context));
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _DraggableSheet(
      getTarget: getTarget,
      route: this,
      routeAnimation: controller!,
      child: child,
    );
  }
}

class _FractionalController extends ChangeNotifier with FractionalDragDelegate {
  _FractionalController({required this.route, required this.routeController});

  final ModalRoute route;
  final AnimationController routeController;

  Offset _offset = Offset.zero;
  Alignment _dragAlignment = Alignment.center;
  double dragEndProgress = 1.0;

  late CurvedAnimation alignmentCurve = CurvedAnimation(
    curve: Curves.fastEaseInToSlowEaseOut.flipped,
    parent: routeController,
  );

  @override
  FutureOr<void> handleDragStart(DragStartDetails details, Alignment alignment) {
    route.navigator?.didStartUserGesture();
    _dragAlignment = alignment;
    _offset = Offset.zero;
    notifyListeners();
  }

  @override
  FutureOr<void> handleDragUpdate(Offset offset) {
    _offset = _offset + offset;
    double progress = 1.0 - min(0.3, max(_offset.dx.abs(), _offset.dy.abs()));
    routeController.value = progress;
    notifyListeners();
  }

  @override
  FutureOr<void> handleDragEnd(double dxVelocityRatio, double dyVelocityRatio) async {
    dragEndProgress = routeController.value;
    if (routeController.value < 0.80) {
      if (route.isCurrent) {
        route.navigator?.pop();
      }
    } else {
      await routeController.forward();
    }
    route.navigator?.didStopUserGesture();
    notifyListeners();
  }

  Alignment getAlignment(Alignment targetAlignment) {
    double progress = routeController.value;
    if ((route.navigator?.userGestureInProgress ?? true) || dragEndProgress == 1.0) {
      return AlignmentTween(begin: targetAlignment, end: _dragAlignment).transform(progress);
    }

    final TweenSequence<Alignment> sequence = TweenSequence([
      TweenSequenceItem(
        tween: AlignmentTween(begin: targetAlignment, end: _dragAlignment),
        weight: dragEndProgress,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(begin: _dragAlignment, end: Alignment.center),
        weight: 1 - dragEndProgress,
      ),
    ]);

    return sequence.transform(routeController.value);
  }

  Offset get offSet {
    if ((route.navigator?.userGestureInProgress ?? true) || dragEndProgress == 1.0) {
      return _offset;
    }

    final TweenSequence<Offset> sequence = TweenSequence([
      TweenSequenceItem(
        tween: OffsetTween(begin: Offset.zero, end: _offset),
        weight: dragEndProgress,
      ),
      TweenSequenceItem(
        tween: OffsetTween(begin: _offset, end: Offset.zero),
        weight: 1 - dragEndProgress,
      ),
    ]);

    return sequence.transform(routeController.value);
  }
}

class OffsetTween extends Tween<Offset> {
  OffsetTween({super.begin, super.end});

  @override
  Offset lerp(double t) => Offset.lerp(begin, end, t)!;
}

class _DraggableSheet extends StatefulWidget {
  const _DraggableSheet({
    required this.getTarget,
    required this.child,
    required this.route,
    required this.routeAnimation,
  });

  final AnimationController routeAnimation;
  final Widget child;
  final ModalRoute route;
  final ResizedRouteTarget Function() getTarget;

  @override
  State<_DraggableSheet> createState() => _DraggableRouteTransition();
}

class _DraggableRouteTransition extends State<_DraggableSheet> with TickerProviderStateMixin {
  late final _FractionalController _fractionalController = _FractionalController(
    route: widget.route,
    routeController: widget.routeAnimation,
  );

  Alignment getAlignment(Size parentSize, Size childSize, Offset offset) {
    final Offset other = (parentSize - childSize) as Offset;
    final double centerX = other.dx / 2.0;
    final double centerY = other.dy / 2.0;
    return Alignment(
      centerX == 0.0 ? -1 : (offset.dx - centerX) / centerX,
      centerY == 0.0 ? -1 : (offset.dy - centerY) / centerY,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget transition = LayoutBuilder(
      builder: (context, constrains) {
        return ListenableBuilder(
          listenable: _fractionalController,
          builder: (context, child) {
            final State target = widget.getTarget();
            RenderBox targetRenderBox = target.context.findRenderObject() as RenderBox;
            RenderObject navigatorRenderBox = widget.route.navigator!.context.findRenderObject()!;

            Size beginSize = targetRenderBox.size;
            Size endSize = constrains.biggest;

            final CurvedAnimation sizedCurved = CurvedAnimation(
              parent: widget.routeAnimation,
              curve: Curves.linear,
            );
            final SizeTween sizeTween = SizeTween(begin: beginSize, end: endSize);
            final Animation<Size?> sizeAnimation = sizedCurved.drive(sizeTween);
            Offset tagetOffset = targetRenderBox.localToGlobal(
              Offset.zero,
              ancestor: navigatorRenderBox,
            );

            Alignment targetAlignment = getAlignment(constrains.biggest, beginSize, tagetOffset);

            return FractionalTranslation(
              translation: _fractionalController.offSet,
              child: Align(
                alignment: _fractionalController.getAlignment(targetAlignment),
                child: SizedBox.fromSize(size: sizeAnimation.value, child: widget.child),
              ),
            );
          },
        );
      },
    );

    return FractionalGestureDetector(
      controller: _fractionalController,
      horizontalEnabled: true,
      verticalEnabled: false,
      child: transition,
    );
  }

  @override
  void dispose() {
    _fractionalController.dispose();
    super.dispose();
  }
}

class ResizingRouteScope extends InheritedWidget {
  const ResizingRouteScope({super.key, required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(covariant ResizingRouteScope oldWidget) {
    return oldWidget.animation != animation;
  }
}
