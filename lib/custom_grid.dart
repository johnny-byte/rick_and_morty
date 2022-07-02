import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class SliverCustomGridLayout extends SliverGridLayout {
  /// Creates a layout that uses equally sized and spaced tiles.
  ///
  /// All of the arguments must not be null and must not be negative. The
  /// `crossAxisCount` argument must be greater than zero.
  SliverCustomGridLayout({
    required this.crossAxisCount,
    required this.mainAxisStride,
    required this.crossAxisStride,
    required this.childMainAxisExtent,
    required this.childCrossAxisExtent,
    required this.startOffset,
    required this.reverseCrossAxis,
  })  : assert(crossAxisCount > 0),
        assert(mainAxisStride >= 0),
        assert(crossAxisStride >= 0),
        assert(childMainAxisExtent >= 0),
        assert(childCrossAxisExtent >= 0) {
    // print("Created");
  }

  final double startOffset;

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the main axis.
  final double mainAxisStride;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the cross axis.
  final double crossAxisStride;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the main axis.
  final double childMainAxisExtent;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  final double childCrossAxisExtent;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return mainAxisStride > precisionErrorTolerance
        ? crossAxisCount * (scrollOffset ~/ mainAxisStride)
        : 0;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    // print("getMaxChildIndexForScrollOffset");
    if (mainAxisStride > 0.0) {
      final int mainAxisCount = (scrollOffset / mainAxisStride).ceil();
      return math.max(0, crossAxisCount * mainAxisCount - 1);
    }
    return 0;
  }

  double _getCrossAxisOffset(int index) {
    return startOffset + (crossAxisStride) * (index % crossAxisCount);
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    return SliverGridGeometry(
      scrollOffset: (index ~/ crossAxisCount) * mainAxisStride,
      crossAxisOffset: _getCrossAxisOffset(index),
      mainAxisExtent: childMainAxisExtent,
      crossAxisExtent: childCrossAxisExtent,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    final int mainAxisCount = ((childCount - 1) ~/ crossAxisCount) + 1;
    final double mainAxisSpacing = mainAxisStride - childMainAxisExtent;
    return mainAxisStride * mainAxisCount - mainAxisSpacing;
  }
}

class CustomSliverGridDelegate extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent.
  ///
  /// All of the arguments except [mainAxisExtent] must not be null.
  /// The [maxCrossAxisExtent], [mainAxisExtent], [mainAxisSpacing],
  /// and [crossAxisSpacing] arguments must not be negative.
  /// The [childAspectRatio] argument must be greater than zero.
  const CustomSliverGridDelegate(
      {required this.height, required this.width, required this.spacing})
      : assert(height > 0),
        assert(width > 0),
        assert(spacing >= 0);

  final double spacing;
  final double width;
  final double height;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final int count =
        (constraints.crossAxisExtent + spacing) ~/ (width + spacing);

    final double startOffset =
        (constraints.crossAxisExtent - ((width + spacing) * count - spacing)) /
            2;

    // final int crossAxisCount =
    //     (constraints.crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing))
    //         .ceil();
    // final double usableCrossAxisExtent = math.max(
    //   0.0,
    //   constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    // );
    // final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    // final double childMainAxisExtent =
    //     mainAxisExtent ?? childCrossAxisExtent / childAspectRatio;
    return SliverCustomGridLayout(
      crossAxisCount: count,
      mainAxisStride: height + spacing,
      crossAxisStride: width + spacing,
      childMainAxisExtent: height,
      childCrossAxisExtent: width,
      startOffset: startOffset,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(CustomSliverGridDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.width != width ||
        oldDelegate.spacing != spacing;
  }
}
