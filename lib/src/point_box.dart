import 'dart:math';

/// A box made up of a [start] [Point], plus a [width] and a [height].
class PointBox {
  /// Create an instance.
  const PointBox({
    required this.start,
    required this.width,
    required this.height,
  }) : assert(width > 0, '`width` must be greater than 0.'),
       assert(height > 0, '`height` must be greater than 0.');

  /// The start point.
  final Point<int> start;

  /// The width of the box.
  final int width;

  /// The height of this box.
  final int height;

  /// The coordinates at the southwest corner of this box.
  ///
  /// This is the same as [start].
  Point<int> get southwest => start;

  /// The coordinates at the southeast of this box.
  Point<int> get southeast => Point(northeast.x, southwest.y);

  /// The coordinates at the northwest of the box.
  Point<int> get northwest => Point(southwest.x, northeast.y);

  /// The coordinates at the northeast of this box.
  Point<int> get northeast => Point(start.x + width - 1, start.y + height - 1);

  /// Returns an iterable of all the points from the [southwest] corner to the
  /// [northeast].
  Iterable<Point<int>> get points sync* {
    final x = start.x;
    final y = start.y;
    for (var i = 0; i < width; i++) {
      for (var j = 0; j < height; j++) {
        yield Point(x + i, y + j);
      }
    }
  }
}
