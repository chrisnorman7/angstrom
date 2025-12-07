import 'dart:math';

import 'package:angstrom/angstrom.dart';

/// An object in a [Room].
class RoomObject {
  /// Create an instance.
  const RoomObject({
    required this.name,
    required this.coordinates,
    this.ambiance,
    this.ambianceMaxDistance = 20,
    this.onApproach,
    this.onLeave,
    this.onActivate,
  });

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
}
