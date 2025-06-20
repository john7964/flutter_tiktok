import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverResizingOverlayHeader extends StatelessWidget {
  /// Create a pinned header sliver that reacts to scrolling by resizing between
  /// the intrinsic sizes of the min and max extent prototypes.
  const SliverResizingOverlayHeader({
    super.key,
    this.minExtentPrototype,
    this.maxExtentPrototype,
    this.child,
  });

  /// Laid out once to define the minimum size of this sliver along the
  /// [CustomScrollView.scrollDirection] axis.
  ///
  /// If null, the minimum size of the sliver is 0.
  ///
  /// This widget is never made visible.
  final Widget? minExtentPrototype;

  /// Laid out once to define the maximum size of this sliver along the
  /// [CustomScrollView.scrollDirection] axis.
  ///
  /// If null, the maximum extent of the sliver is based on the child's
  /// intrinsic size.
  ///
  /// This widget is never made visible.
  final Widget? maxExtentPrototype;

  /// The widget contained by this sliver.
  final Widget? child;

  Widget? _excludeFocus(Widget? extentPrototype) {
    return extentPrototype != null ? ExcludeFocus(child: extentPrototype) : null;
  }

  @override
  Widget build(BuildContext context) {
    return _SliverResizingHeader(
      minExtentPrototype: _excludeFocus(minExtentPrototype),
      maxExtentPrototype: _excludeFocus(maxExtentPrototype),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

enum _Slot { minExtent, maxExtent, child }

class _SliverResizingHeader extends SlottedMultiChildRenderObjectWidget<_Slot, RenderBox> {
  const _SliverResizingHeader({
    this.minExtentPrototype,
    this.maxExtentPrototype,
    required this.child,
  });

  final Widget? minExtentPrototype;
  final Widget? maxExtentPrototype;
  final Widget child;

  @override
  Iterable<_Slot> get slots => _Slot.values;

  @override
  Widget? childForSlot(_Slot slot) {
    return switch (slot) {
      _Slot.minExtent => minExtentPrototype,
      _Slot.maxExtent => maxExtentPrototype,
      _Slot.child => child,
    };
  }

  @override
  _RenderSliverResizingHeader createRenderObject(BuildContext context) {
    return _RenderSliverResizingHeader();
  }
}

class _RenderSliverResizingHeader extends RenderSliver
    with SlottedContainerRenderObjectMixin<_Slot, RenderBox>, RenderSliverHelpers {
  RenderBox? get minExtentPrototype => childForSlot(_Slot.minExtent);

  RenderBox? get maxExtentPrototype => childForSlot(_Slot.maxExtent);

  RenderBox? get child => childForSlot(_Slot.child);

  @override
  Iterable<RenderBox> get children => <RenderBox>[
    if (minExtentPrototype != null) minExtentPrototype!,
    if (maxExtentPrototype != null) maxExtentPrototype!,
    if (child != null) child!,
  ];

  double boxExtent(RenderBox box) {
    assert(box.hasSize);
    return switch (constraints.axis) {
      Axis.vertical => box.size.height,
      Axis.horizontal => box.size.width,
    };
  }

  double get childExtent => child == null ? 0 : boxExtent(child!);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @protected
  void setChildParentData(
    RenderObject child,
    SliverConstraints constraints,
    SliverGeometry geometry,
  ) {
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    final AxisDirection direction = applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    );
    childParentData.paintOffset = switch (direction) {
      AxisDirection.up => Offset(
        0.0,
        -(geometry.scrollExtent - (geometry.paintExtent + constraints.scrollOffset)),
      ),
      AxisDirection.right => Offset(-constraints.scrollOffset, 0.0),
      AxisDirection.down => Offset(0.0, -constraints.scrollOffset),
      AxisDirection.left => Offset(
        -(geometry.scrollExtent - (geometry.paintExtent + constraints.scrollOffset)),
        0.0,
      ),
    };
  }

  @override
  double childMainAxisPosition(covariant RenderObject child) => 0;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final BoxConstraints prototypeBoxConstraints = constraints.asBoxConstraints();

    double minExtent = 0;
    if (minExtentPrototype != null) {
      minExtentPrototype!.layout(prototypeBoxConstraints, parentUsesSize: true);
      minExtent = boxExtent(minExtentPrototype!);
    }

    late final double maxExtent;
    if (maxExtentPrototype != null) {
      maxExtentPrototype!.layout(prototypeBoxConstraints, parentUsesSize: true);
      maxExtent = boxExtent(maxExtentPrototype!);
    } else {
      final Size childSize = child!.getDryLayout(prototypeBoxConstraints);
      maxExtent = switch (constraints.axis) {
        Axis.vertical => childSize.height,
        Axis.horizontal => childSize.width,
      };
    }

    final double overScrolled = constraints.overlap < 0 ? constraints.overlap.abs() : 0.0;
    final double scrollOffset = constraints.scrollOffset;
    final double shrinkOffset = math.min(scrollOffset, maxExtent);
    final BoxConstraints boxConstraints = constraints.asBoxConstraints(
      minExtent: minExtent,
      maxExtent: math.max(minExtent, maxExtent - shrinkOffset + overScrolled),
    );
    child?.layout(boxConstraints, parentUsesSize: true);

    final double remainingPaintExtent = constraints.remainingPaintExtent;
    final double layoutExtent = childExtent - overScrolled;
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, remainingPaintExtent),
      layoutExtent: clampDouble(layoutExtent, 0, remainingPaintExtent),
      maxPaintExtent: childExtent,
      maxScrollObstructionExtent: minExtent,
      cacheExtent: calculateCacheOffset(constraints, from: 0.0, to: childExtent),
      hasVisualOverflow: true, // Conservatively say we do have overflow to avoid complexity.
    );
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final SliverPhysicalParentData childParentData = child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    assert(geometry!.hitTestExtent > 0.0);
    if (child != null) {
      return hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        child!,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
    }
    return false;
  }
}
