import 'dart:math';

import 'package:angstrom/angstrom.dart';

/// Useful methods for [int] [Point]s.
extension PointIntX on Point<int> {
  /// The the [Point] which lies [distance] in [direction].
  Point<int> pointInDirection(
    final FacingDirection direction, {
    final int distance = 1,
  }) {
    switch (direction) {
      case FacingDirection.north:
        return Point(x, y + distance);
      case FacingDirection.east:
        return Point(x + distance, y);
      case FacingDirection.south:
        return Point(x, y - distance);
      case FacingDirection.west:
        return Point(x - distance, y);
    }
  }

  /// Calculates the points between `this` point and [end].
  Iterable<Point<int>> bresenham(final Point<int> end) sync* {
    final start = this;
    var x0 = start.x;
    var y0 = start.y;
    final x1 = end.x;
    final y1 = end.y;

    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;

    var err = dx - dy;

    while (true) {
      // yield current tile
      yield Point<int>(x0, y0);

      // reached the end
      if (x0 == x1 && y0 == y1) {
        break;
      }

      final e2 = 2 * err;

      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }
  }
}

/// Useful methods for [String]s.
extension StringX on String {
  /// Convert `this` [String] into a [SoundReference].
  SoundReference asSoundReference({final double volume = 0.7}) =>
      SoundReference(path: this, volume: volume);
}
