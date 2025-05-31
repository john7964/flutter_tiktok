import 'package:flutter/cupertino.dart';

class SliverPersistentHeaderBox extends SliverPersistentHeader {
  SliverPersistentHeaderBox({
    super.key,
    required Widget child,
    required double minExtent,
    required double maxExtent,
    super.floating,
    super.pinned,
  }) : super(
         delegate: ShortsSliverPersistentBuilderDelegate(
           minExtent: minExtent,
           maxExtent: maxExtent,
           child: child,
         ),
       );
}

class ShortsSliverPersistentBuilderDelegate extends SliverPersistentHeaderDelegate {
  ShortsSliverPersistentBuilderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  final Widget child;
  @override
  final double minExtent;
  @override
  final double maxExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant ShortsSliverPersistentBuilderDelegate oldDelegate) {
    return (oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.child != child);
  }
}
