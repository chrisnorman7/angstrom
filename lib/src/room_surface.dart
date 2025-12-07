import 'dart:math';

import 'package:angstrom/angstrom.dart';

/// A surface in a [Room].
class RoomSurface {
  /// Create an instance.
  const RoomSurface({
    required this.points,
    required this.contactSounds,
    this.contactSoundsVolume = 0.7,
    this.isWall = false,
    this.moveInterval = const Duration(milliseconds: 500),
    this.onEnter,
    this.onMove,
    this.onExit,
    this.ambiance,
  });

  /// The points which this surface inhabits.
  final Set<Point<int>> points;

  /// Whether this surface is a wass or not.
  final bool isWall;

  /// How often the player can move on this surface.
  final Duration moveInterval;

  /// The paths to the contact sounds for this surface.
  ///
  /// If [isWall] is `true`, then a sound from [contactSounds] will play when
  /// the player walks into this wall. Otherwise, they are the sounds which will
  /// be heard when the player walks on this surface.
  final List<String> contactSounds;

  /// The volume to play [contactSounds] at.
  final double contactSoundsVolume;

  /// The function to call when the player enters this surface.
  ///
  /// If [isWall ] is `true`, this function will be called when the player
  /// collides with this surface. Otherwise, it will be called when the player
  /// leaves another surface and enters this one.
  final AngstromCallback? onEnter;

  /// The function to call when the player moves on this surface.
  ///
  /// If [isWall] is `true`, this function will *never* be called.
  final AngstromCallback? onMove;

  /// The function to call when the player leaves this surface.
  ///
  /// If [isWall] is `true`, this method will never be called.
  final AngstromCallback? onExit;

  /// The ambiance to play while the player is traversing this surface.
  final SoundReference? ambiance;

  /// Make surfaces comparable.
  @override
  int get hashCode => points.hashCode;

  @override
  bool operator ==(final Object other) {
    if (other is RoomSurface) {
      return other.points == points;
    }
    return super == other;
  }
}
