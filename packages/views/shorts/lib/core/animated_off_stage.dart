import 'package:flutter/cupertino.dart';

typedef OpacityBuilder = Widget Function(BuildContext context, double opacity, Widget? child);

class AnimatedOpacityOffStage extends ImplicitlyAnimatedWidget {
  const AnimatedOpacityOffStage({
    super.key,
    required this.opacity,
    this.child,
    this.builder,
    super.curve,
    super.duration = const Duration(milliseconds: 100),
  });

  final double opacity;
  final Widget? child;
  final OpacityBuilder? builder;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedOpacityOffStage> createState() =>
      _AnimatedOpacityOffStageState();
}

class _AnimatedOpacityOffStageState extends ImplicitlyAnimatedWidgetState<AnimatedOpacityOffStage> {
  Tween<double>? _opacity;
  late Animation<double> _opacityAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _opacity =
        visitor(_opacity, widget.opacity, (dynamic value) => Tween<double>(begin: value as double))
            as Tween<double>?;
  }

  @override
  void didUpdateTweens() {
    _opacityAnimation = animation.drive(_opacity!);
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: widget.opacity == 0.0,
      child: FadeTransition(opacity: _opacityAnimation, child: widget.child),
    );
  }
}
