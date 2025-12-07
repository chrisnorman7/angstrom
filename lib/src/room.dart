import 'package:angstrom/angstrom.dart';

/// A room in the game.
abstract class Room {
  /// Create an instance.
  const Room();

  /// The unique String ID of this room.
  String get id;

  /// The surfaces in this room.
  List<RoomSurface> get surfaces;

  /// The objects in this room.
  List<RoomObject> get objects => [];

  /// The music which will play in this room.
  SoundReference? get music => null;

  /// The function to call when the player enters this room.
  void onEnter(final AngstromEngine engine) {}

  /// The function to call when the player leaves this room.
  void onLeave(final AngstromEngine engine) {}

  /// The hash code for this room.
  @override
  int get hashCode => id.hashCode;

  /// Make rooms comparable.
  @override
  bool operator ==(final Object other) {
    if (other is Room) {
      return other.id == id;
    }
    return super == other;
  }
}
