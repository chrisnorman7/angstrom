import 'dart:math';

import 'package:angstrom/angstrom.dart';

/// Convert any [RoomObject] into a door.
class Door {
  /// Create an instance.
  Door({
    required this.coordinates,
    required this.destinationId,
    this.stopPlayer = false,
    this.useSound,
  });

  /// The coordinates the player will end up at.
  final Point<int> coordinates;

  /// The ID of the destination room.
  final String destinationId;

  /// Whether the player should be stopped from walking when they use this door.
  final bool stopPlayer;

  /// The path to the sound to play when this door is used.
  final SoundReference? useSound;

  /// The function to use as the [RoomObject]'s `onActivate` callback.
  void onActivate(final AngstromEngine engine) {
    if (stopPlayer) {
      engine.stopPlayerMoving();
    }
    final sound = useSound;
    if (sound != null) {
      engine.playInterfaceSound(sound);
    }
    engine.teleportPlayer(destinationId, coordinates);
  }
}
