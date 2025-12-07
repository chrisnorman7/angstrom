import 'dart:math';

import 'package:angstrom/angstrom.dart' show RoomObject;
import 'package:angstrom/src/room_object.dart' show RoomObject;
import 'package:json_annotation/json_annotation.dart';

part 'room_object_ambiance.g.dart';

/// An ambiance for a [RoomObject].
@JsonSerializable()
class RoomObjectAmbiance {
  /// Create an instance.
  const RoomObjectAmbiance({
    required this.path,
    required this.x,
    required this.y,
    required this.volume,
    required this.ambianceMaxDistance,
  });

  /// Create an instance from a JSON object.
  factory RoomObjectAmbiance.fromJson(final Map<String, dynamic> json) =>
      _$RoomObjectAmbianceFromJson(json);

  /// The path to the sound to play.
  final String path;

  /// The volume of the sound.
  final double volume;

  /// The maximum distance at which this ambiance will be heard.
  final int ambianceMaxDistance;

  /// The x coordinate of the object.
  final int x;

  /// The y coordinate of the object.
  final int y;

  /// The coordinates of the object.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Point<int> get coordinates => Point(x, y);

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RoomObjectAmbianceToJson(this);
}
