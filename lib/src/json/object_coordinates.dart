import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'object_coordinates.g.dart';

/// Provides the [x] and [y] [coordinates] for an object.
@JsonSerializable()
class ObjectCoordinates {
  /// Create an instance.
  const ObjectCoordinates(this.x, this.y);

  /// Create an instance from a JSON object.
  factory ObjectCoordinates.fromJson(final Map<String, dynamic> json) =>
      _$ObjectCoordinatesFromJson(json);

  /// The x coordinate.
  final int x;

  /// The y coordinate.
  final int y;

  /// The [x] and [y] coordinates as a [Point].
  @JsonKey(includeFromJson: false, includeToJson: false)
  Point<int> get coordinates => Point(x, y);

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$ObjectCoordinatesToJson(this);
}
