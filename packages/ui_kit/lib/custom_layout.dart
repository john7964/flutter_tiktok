import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

abstract class SizedBoxBuilderDelegate {
  Size getSize(BoxConstraints constraints, Size childSize) => constraints.constrain(childSize);

  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints;
}

class SizedBoxBuilderSizeDelegate extends SizedBoxBuilderDelegate {
  SizedBoxBuilderSizeDelegate(this.sizeBuilder);

  final Size Function(BoxConstraints constraints, Size childSize) sizeBuilder;

  @override
  Size getSize(BoxConstraints constraints, Size childSize) => sizeBuilder(constraints, childSize);
}

class SizedBoxBuilderConstrainsDelegate extends SizedBoxBuilderDelegate {
  SizedBoxBuilderConstrainsDelegate(this.constrainsBuilder);

  final BoxConstraints Function(BoxConstraints constraints) constrainsBuilder;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constrainsBuilder(constraints);
}

class SizedBoxBuilder extends SingleChildRenderObjectWidget {
  const SizedBoxBuilder({
    super.key,
    super.child,
    required this.delegate,
    this.alignment = Alignment.topCenter,
  });

  SizedBoxBuilder.forSize({
    super.key,
    super.child,
    required Size Function(BoxConstraints constraints, Size childSize) sizeBuilder,
    this.alignment = Alignment.topCenter,
  }) : delegate = SizedBoxBuilderSizeDelegate(sizeBuilder);

  SizedBoxBuilder.forChildConstrains({
    super.key,
    super.child,
    required BoxConstraints Function(BoxConstraints constraints) constrainsBuilder,
    this.alignment = Alignment.topCenter,
  }) : delegate = SizedBoxBuilderConstrainsDelegate(constrainsBuilder);

  final SizedBoxBuilderDelegate delegate;
  final AlignmentGeometry alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSizedOverFlowBoxBuilder(
      alignment: alignment,
      delegate: delegate,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSizedOverFlowBoxBuilder renderObject) {
    renderObject
      ..alignment = alignment
      ..delegate = delegate
      ..textDirection = Directionality.of(context);
  }
}

class RenderSizedOverFlowBoxBuilder extends RenderAligningShiftedBox {
  RenderSizedOverFlowBoxBuilder({
    super.child,
    super.textDirection,
    super.alignment,
    required SizedBoxBuilderDelegate delegate,
  }) : _delegate = delegate;

  SizedBoxBuilderDelegate get delegate => _delegate;
  SizedBoxBuilderDelegate _delegate;

  set delegate(SizedBoxBuilderDelegate newDelegate) {
    if (_delegate == newDelegate) {
      return;
    }
    _delegate = newDelegate;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    child!.layout(delegate.getConstraintsForChild(constraints), parentUsesSize: true);
    size = constraints.constrain(delegate.getSize(constraints, child!.size));
    alignChild();
  }

  @override
  @protected
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return child?.getDryLayout(constraints) ?? constraints.smallest;
  }

  @override
  double? computeDryBaseline(covariant BoxConstraints constraints, TextBaseline baseline) {
    final RenderBox? child = this.child;
    if (child == null) {
      return null;
    }
    final double? result = child.getDryBaseline(constraints, baseline);
    if (result == null) {
      return null;
    }
    final Size childSize = child.getDryLayout(constraints);
    final Size size = getDryLayout(constraints);
    return result + resolvedAlignment.alongOffset(size - childSize as Offset).dy;
  }
}
