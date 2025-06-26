import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class SliverAlign extends SingleChildRenderObjectWidget {
  const SliverAlign({super.key, required Widget sliver, this.mainAxisExtent})
    : super(child: sliver);
  final double? mainAxisExtent;

  @override
  RenderSliverAlign createRenderObject(BuildContext context) {
    return RenderSliverAlign(mainAxisExtent: mainAxisExtent);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverAlign renderObject) {
    renderObject.mainAxisExtent = mainAxisExtent;
  }
}

class RenderSliverAlign extends RenderSliver with RenderObjectWithChildMixin<RenderSliver> {
  RenderSliverAlign({double? mainAxisExtent}) : _mainAxisExtent = mainAxisExtent;

  double? _mainAxisExtent;

  double? get mainAxisExtent => _mainAxisExtent;

  set mainAxisExtent(double? value) {
    if (_mainAxisExtent == value) {
      return;
    }
    _mainAxisExtent = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalContainerParentData) {
      child.parentData = SliverPhysicalContainerParentData();
    }
  }

  @override
  double childMainAxisPosition(RenderSliver child) {
    final Offset paintOffset = (child.parentData! as SliverPhysicalParentData).paintOffset;
    return switch (constraints.axis) {
      Axis.horizontal => paintOffset.dx,
      Axis.vertical => paintOffset.dy,
    };
  }

  @override
  double childCrossAxisPosition(RenderSliver child) => 0.0;

  double beforePadding = 0.0;

  @override
  void performLayout() {
    beforePadding = 0.0;
    double paintOffset({required double from, required double to}) =>
        calculatePaintOffset(constraints, from: from, to: to);
    double cacheOffset({required double from, required double to}) =>
        calculateCacheOffset(constraints, from: from, to: to);
    double beforePaddingPaintExtent = paintOffset(from: 0.0, to: beforePadding);
    child!.layout(constraints, parentUsesSize: true);
    SliverGeometry childLayoutGeometry = child!.geometry!;
    double scrollExtent = childLayoutGeometry.scrollExtent;

    if (scrollExtent < (mainAxisExtent ?? constraints.viewportMainAxisExtent)) {
      beforePadding = (mainAxisExtent ?? constraints.viewportMainAxisExtent) - scrollExtent;
      beforePaddingPaintExtent = paintOffset(from: 0.0, to: beforePadding);
      child!.layout(
        constraints.copyWith(
          scrollOffset: math.max(0.0, constraints.scrollOffset - beforePadding),
          cacheOrigin: math.min(0.0, constraints.cacheOrigin + beforePadding),
          overlap: math.max(0.0, constraints.overlap - beforePaddingPaintExtent),
          remainingPaintExtent:
              constraints.remainingPaintExtent - paintOffset(from: 0.0, to: beforePadding),
          remainingCacheExtent:
              constraints.remainingCacheExtent - cacheOffset(from: 0.0, to: beforePadding),
          crossAxisExtent: constraints.crossAxisExtent,
          precedingScrollExtent: beforePadding + constraints.precedingScrollExtent,
        ),
        parentUsesSize: true,
      );
      childLayoutGeometry = child!.geometry!;
      scrollExtent = childLayoutGeometry.scrollExtent;
    }
    if (childLayoutGeometry.scrollOffsetCorrection != null) {
      geometry = SliverGeometry(scrollOffsetCorrection: childLayoutGeometry.scrollOffsetCorrection);
      return;
    }
    final double beforePaddingCacheExtent = cacheOffset(from: 0.0, to: beforePadding);
    final double paintExtent = math.min(
      beforePaddingPaintExtent +
          math.max(childLayoutGeometry.paintExtent, childLayoutGeometry.layoutExtent),
      constraints.remainingPaintExtent,
    );

    geometry = SliverGeometry(
      paintOrigin: childLayoutGeometry.paintOrigin,
      scrollExtent: beforePadding + scrollExtent,
      paintExtent: paintExtent,
      layoutExtent: math.min(
        beforePaddingPaintExtent + childLayoutGeometry.layoutExtent,
        paintExtent,
      ),
      cacheExtent: math.min(
        beforePaddingCacheExtent + childLayoutGeometry.cacheExtent,
        constraints.remainingCacheExtent,
      ),
      maxPaintExtent: beforePadding + childLayoutGeometry.maxPaintExtent,
      hitTestExtent: math.max(
        beforePaddingPaintExtent + childLayoutGeometry.paintExtent,
        beforePaddingPaintExtent + childLayoutGeometry.hitTestExtent,
      ),
      hasVisualOverflow: childLayoutGeometry.hasVisualOverflow,
    );

    final double calculatedOffset = switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      AxisDirection.up => paintOffset(
        from: beforePadding + scrollExtent,
        to: beforePadding + scrollExtent,
      ),
      AxisDirection.left => paintOffset(
        from: beforePadding + scrollExtent,
        to: beforePadding + scrollExtent,
      ),
      AxisDirection.right => paintOffset(from: 0.0, to: beforePadding),
      AxisDirection.down => paintOffset(from: 0.0, to: beforePadding),
    };

    final SliverPhysicalParentData childParentData = child!.parentData! as SliverPhysicalParentData;
    childParentData.paintOffset = switch (constraints.axis) {
      Axis.horizontal => Offset(calculatedOffset, 0.0),
      Axis.vertical => Offset(0.0, calculatedOffset),
    };
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (child != null && child!.geometry!.hitTestExtent > 0.0) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      return result.addWithAxisOffset(
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
        mainAxisOffset: childMainAxisPosition(child!),
        crossAxisOffset: childCrossAxisPosition(child!),
        paintOffset: childParentData.paintOffset,
        hitTest: child!.hitTest,
      );
    }
    return false;
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    return beforePadding;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child == this.child);
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.geometry!.visible) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }
}
