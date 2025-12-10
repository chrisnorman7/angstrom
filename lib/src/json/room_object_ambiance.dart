import 'dart:math';

import 'package:angstrom/angstrom.dart' show RoomObject, SoundReference;
import 'package:json_annotation/json_annotation.dart';

part 'room_object_ambiance.g.dart';

/// An ambiance for a [RoomObject].
@JsonSerializable()
class RoomObjectAmbiance {
  /// Create an instance.
  const RoomObjectAmbiance({
    required this.id,
    required this.soundReference,
    required this.x,
    required this.y,
    required this.ambianceMaxDistance,
  });

  /// Create an instance from a JSON object.
  factory RoomObjectAmbiance.fromJson(final Map<String, dynamic> json) =>
      _$RoomObjectAmbianceFromJson(json);

  /// The ID of this object whose ambiance this instance represents.
  final String id;

  /// The sound reference to play.
  final SoundReference soundReference;

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
