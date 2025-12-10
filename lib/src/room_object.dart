import 'dart:math';

import 'package:angstrom/angstrom.dart';

/// An object in a [Room].
class RoomObject {
  /// Create an instance.
  const RoomObject({
    required this.id,
    required this.name,
    required this.coordinates,
    this.ambiance,
    this.ambianceMaxDistance = 20,
    this.onApproach,
    this.onLeave,
    this.onActivate,
  });

  /// The ID of this object.
  final String id;

  /// The name of this object.
  final String name;

  /// The coordinates of this object.
  final Point<int> coordinates;

  /// The ambiance for this object.
  final SoundReference? ambiance;

  /// The max distance at which this object's [ambiance] will be heard.
  final int ambianceMaxDistance;

  /// The function to call when the player arrives at [coordinates].
  final AngstromCallback? onApproach;

  /// The function to call when the player leaves [coordinates].
  final AngstromCallback? onLeave;

  /// The function to call when the player triggers activation at [coordinates].
  final AngstromCallback? onActivate;

  /// Make [RoomObject]s findable.
  @override
  int get hashCode => id.hashCode;

  /// Compare to [other] by [id], if [other] is a [RoomObject].
  @override
  bool operator ==(final Object other) {
    if (other is RoomObject) {
      return other.id == id;
    }
    return super == other;
  }
}
