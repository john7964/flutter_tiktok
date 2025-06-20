import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ui_kit/draggable.dart';

mixin ResizedRouteTarget<T extends StatefulWidget> on State<T> {
  void didChangedFraction(double fraction);
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

  static ResizingRouteScope? maybeOf(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<ResizingRouteScope>();
  }

  final Widget Function(BuildContext context) builder;
  final ResizedRouteTarget Function() getTarget;
  late final _FractionalController _fractionalController;
  final ValueNotifier<double> fractionNotifier = ValueNotifier(0.0);

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

  void handleAnimationChanged() {
    fractionNotifier.value = _fractionalController.scale * controller!.value;
  }

  void handleFractionChanged() {
    getTarget().didChangedFraction(fractionNotifier.value);
  }

  @override
  void install() {
    super.install();
    _fractionalController = _FractionalController(route: this);
    _fractionalController.addListener(handleAnimationChanged);
    fractionNotifier.addListener(handleFractionChanged);
    controller!.addListener(handleAnimationChanged);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return ResizingRouteScope(fraction: fractionNotifier, child: builder(context));
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _DraggableSheet(
      target: getTarget(),
      route: this,
      routeAnimation: controller!,
      fractionalController: _fractionalController,
      child: child,
    );
  }

  @override
  void dispose() {
    _fractionalController.dispose();
    fractionNotifier.dispose();
    super.dispose();
  }
}

class _FractionalController extends ChangeNotifier with FractionalDragDelegate {
  _FractionalController({required this.route});

  final ModalRoute route;
  late final AnimationController _animationController = AnimationController(
    vsync: route.navigator!,
    duration: Duration(milliseconds: 300),
  );

  Offset offset = Offset.zero;
  Alignment alignment = Alignment.center;
  double scale = 1.0;
  bool isDragging = false;

  @override
  FutureOr<void> handleDragStart(DragStartDetails details, Alignment alignment) {
    isDragging = true;
    this.alignment = alignment;
    offset = Offset.zero;
    notifyListeners();
  }

  @override
  FutureOr<void> handleDragUpdate(Offset offset) {
    this.offset = this.offset + offset;
    scale = 1.0 - min(0.3, max(this.offset.dx.abs(), this.offset.dy.abs()));
    notifyListeners();
  }

  @override
  FutureOr<void> handleDragEnd(double dxVelocityRatio, double dyVelocityRatio) async {
    if (scale < 0.80) {
      if (route.isCurrent) {
        route.navigator?.pop();
        isDragging = false;
      }
    } else {
      OffsetTween offsetTween = OffsetTween(begin: offset, end: Offset.zero);
      AlignmentTween alignmentTween = AlignmentTween(begin: alignment, end: Alignment.center);
      Tween<double> scaleTween = Tween(begin: scale, end: 1.0);
      void listener() {
        offset = offsetTween.lerp(_animationController.value);
        alignment = alignmentTween.lerp(_animationController.value);
        scale = scaleTween.lerp(_animationController.value);
        notifyListeners();
      }

      _animationController.addListener(listener);
      await _animationController.forward(from: 0);
      isDragging = false;
      _animationController.removeListener(listener);
      notifyListeners();
    }
  }
}

class OffsetTween extends Tween<Offset> {
  OffsetTween({super.begin, super.end});

  @override
  Offset lerp(double t) => Offset.lerp(begin, end, t)!;
}

class _DraggableSheet extends StatefulWidget {
  const _DraggableSheet({
    required this.target,
    required this.child,
    required this.route,
    required this.routeAnimation,
    required this.fractionalController,
  });

  final ResizedRouteTarget target;
  final Animation<double> routeAnimation;
  final Widget child;
  final ModalRoute route;
  final _FractionalController fractionalController;

  @override
  State<_DraggableSheet> createState() => _DraggableRouteTransition();
}

class _DraggableRouteTransition extends State<_DraggableSheet> with TickerProviderStateMixin {
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
          listenable: widget.fractionalController,
          builder: (context, child) {
            RenderBox targetRenderBox = widget.target.context.findRenderObject() as RenderBox;
            RenderObject navigatorRenderBox = widget.route.navigator!.context.findRenderObject()!;

            Size beginSize = targetRenderBox.size;
            Size endSize = Size(
              constrains.maxWidth * widget.fractionalController.scale,
              constrains.maxHeight * widget.fractionalController.scale,
            );

            final CurvedAnimation sizedCurved = CurvedAnimation(
              parent: widget.routeAnimation,
              curve: Curves.fastEaseInToSlowEaseOut,
              reverseCurve: Curves.fastEaseInToSlowEaseOut,
            );
            final SizeTween sizeTween = SizeTween(begin: beginSize, end: endSize);
            final Animation<Size?> sizeAnimation = sizedCurved.drive(sizeTween);

            Offset tagetOffset = targetRenderBox.localToGlobal(
              Offset.zero,
              ancestor: navigatorRenderBox,
            );
            Alignment targetAlignment = getAlignment(constrains.biggest, beginSize, tagetOffset);
            AlignmentTween alignmentTween = AlignmentTween(
              begin: targetAlignment,
              end: widget.fractionalController.alignment,
            );

            Animation<Alignment> alignmentAnimation = CurvedAnimation(
              curve: Curves.fastEaseInToSlowEaseOut.flipped,
              parent: widget.routeAnimation,
            ).drive(alignmentTween);

            OffsetTween offsetTween = OffsetTween(
              begin: Offset.zero,
              end: widget.fractionalController.offset,
            );
            return FractionalTranslation(
              translation: offsetTween.lerp(widget.routeAnimation.value),
              child: Align(
                alignment: alignmentAnimation.value,
                child: SizedBox.fromSize(size: sizeAnimation.value, child: widget.child),
              ),
            );
          },
        );
      },
    );

    return FractionalGestureDetector(
      controller: widget.fractionalController,
      horizontalEnabled: true,
      verticalEnabled: false,
      child: transition,
    );
  }
}

class ResizingRouteScope extends InheritedWidget {
  const ResizingRouteScope({super.key, required this.fraction, required super.child});

  final ValueNotifier<double> fraction;

  @override
  bool updateShouldNotify(covariant ResizingRouteScope oldWidget) {
    return oldWidget.fraction != fraction;
  }
}
