import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:json_annotation/json_annotation.dart';

part 'angstrom_events.g.dart';

/// The top-level class for Angstrom events.
sealed class AngstromEvent {
  /// Create an instance.
  const AngstromEvent();
}

/// The engine wants [text] to be spoken.
@JsonSerializable()
class SpeakEvent extends AngstromEvent {
  /// Create an instance.
  const SpeakEvent({required this.text, this.interrupt = true});

  /// Create an instance from a JSON object.
  factory SpeakEvent.fromJson(final Map<String, dynamic> json) =>
      _$SpeakEventFromJson(json);

  /// The text to be spoken.
  final String text;

  /// Whether the speaking of [text] should interrupt other speech.
  final bool interrupt;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$SpeakEventToJson(this);
}

/// The player's coordinates have changed.
@JsonSerializable()
class PlayerCoordinates extends AngstromEvent {
  /// Create an instance.
  const PlayerCoordinates({required this.x, required this.y});

  /// Create an instance from a JSON object.
  factory PlayerCoordinates.fromJson(final Map<String, dynamic> json) =>
      _$PlayerCoordinatesFromJson(json);

  /// The player's x coordinate.
  final int x;

  /// The player's y coordinate.
  final int y;

  /// The player's coordinates.
  Point<int> get coordinates => Point(x, y);

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$PlayerCoordinatesToJson(this);
}

/// Play a footstep sound for the player.
@JsonSerializable()
class PlayerFootstepSound extends AngstromEvent {
  /// Create an instance.
  const PlayerFootstepSound({
    required this.footstepSounds,
    required this.volume,
  });

  /// Create an instance from a JSON object.
  factory PlayerFootstepSound.fromJson(final Map<String, dynamic> json) =>
      _$PlayerFootstepSoundFromJson(json);

  /// The list of paths to footstep sounds.
  final List<String> footstepSounds;

  /// The volume to play the footstep sounds at.
  final double volume;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$PlayerFootstepSoundToJson(this);
}

/// Play some music.
@JsonSerializable()
class PlayMusic extends AngstromEvent {
  /// Create an instance.
  const PlayMusic({this.music});

  /// Create an instance from a JSON object.
  factory PlayMusic.fromJson(final Map<String, dynamic> json) =>
      _$PlayMusicFromJson(json);

  /// The reference to play.
  ///
  /// If [music] is `null`, then the music should stop.
  final SoundReference? music;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$PlayMusicToJson(this);
}

/// The player has either stopped or changed direction.
@JsonSerializable()
class PlayerMoving extends AngstromEvent {
  /// Create an instance.
  const PlayerMoving({this.direction});

  /// Create an instance from a JSON object.
  factory PlayerMoving.fromJson(final Map<String, dynamic> json) =>
      _$PlayerMovingFromJson(json);

  /// The direction of travel.
  ///
  /// If [direction] is `null`, the player has stopped moving.
  final FacingDirection? direction;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$PlayerMovingToJson(this);
}

/// Play an interface sound.
@JsonSerializable()
class InterfaceSound extends AngstromEvent {
  /// Create an instance.
  const InterfaceSound({required this.soundReference});

  /// Create an instance from a JSON object.
  factory InterfaceSound.fromJson(final Map<String, dynamic> json) =>
      _$InterfaceSoundFromJson(json);

  /// The sound to play.
  final SoundReference soundReference;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$InterfaceSoundToJson(this);
}

/// Play room object ambiances.
///
/// When this event is received, the client should stop all previous object
/// ambiances.
@JsonSerializable()
class RoomObjectAmbiances extends AngstromEvent {
  /// Create an instance.
  const RoomObjectAmbiances({required this.ambiances});

  /// Create an instance from a JSON object.
  factory RoomObjectAmbiances.fromJson(final Map<String, dynamic> json) =>
      _$RoomObjectAmbiancesFromJson(json);

  /// The ambiances that should play.
  final List<RoomObjectAmbiance> ambiances;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RoomObjectAmbiancesToJson(this);
}

/// Play a surface ambiance.
///
/// If [ambiance] is `null`, then the client should stop playing any surface
/// ambiance.
@JsonSerializable()
class RoomSurfaceAmbiance extends AngstromEvent {
  /// Create an instance.
  const RoomSurfaceAmbiance({this.ambiance});

  /// Create an instance from a JSON object.
  factory RoomSurfaceAmbiance.fromJson(final Map<String, dynamic> json) =>
      _$RoomSurfaceAmbianceFromJson(json);

  /// The ambiance to play.
  final SoundReference? ambiance;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RoomSurfaceAmbianceToJson(this);
}

/// Provide a list of [walls] in a [Room].
@JsonSerializable()
class RoomWalls extends AngstromEvent {
  /// Create an instance.
  const RoomWalls({required this.walls});

  /// Create an instance from a JSON object.
  factory RoomWalls.fromJson(final Map<String, dynamic> json) =>
      _$RoomWallsFromJson(json);

  /// The walls in the room.
  final List<ObjectCoordinates> walls;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RoomWallsToJson(this);
}

/// Send the movement interval.
///
/// The [moveInterval] is used for applying effects.
@JsonSerializable()
class MoveInterval extends AngstromEvent {
  /// Create an instance.
  const MoveInterval({required this.moveInterval});

  /// Create an instance from a JSON object.
  factory MoveInterval.fromJson(final Map<String, dynamic> json) =>
      _$MoveIntervalFromJson(json);

  /// The time which must elapse between player footsteps.
  final Duration moveInterval;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$MoveIntervalToJson(this);
}

/// Play a 3d sound [reference] at [x], [y], [z].
///
/// *Note*: It is entirely up to the sound system how it interprets these
/// coordinates.
@JsonSerializable()
class Play3dSound extends AngstromEvent {
  /// Create an instance.
  const Play3dSound({
    required this.reference,
    required this.x,
    required this.y,
    required this.z,
    required this.maxDistance,
  });

  /// Create an instance from a JSON object.
  factory Play3dSound.fromJson(final Map<String, dynamic> json) =>
      _$Play3dSoundFromJson(json);

  /// The sound to play.
  final SoundReference reference;

  /// The x coordinate of the sound.
  final double x;

  /// The y coordinate of the sound.
  final double y;

  /// The z coordinate of the sound.
  final double z;

  /// The maximum distance at which this sound will be audible.
  final int maxDistance;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$Play3dSoundToJson(this);
}

/// Tell the client about a [RoomObject].
@JsonSerializable()
class RoomObjectReference extends AngstromEvent {
  /// Create an instance.
  const RoomObjectReference({
    required this.name,
    required this.x,
    required this.y,
  });

  /// Create an instance from a JSON object.
  factory RoomObjectReference.fromJson(final Map<String, dynamic> json) =>
      _$RoomObjectReferenceFromJson(json);

  /// The name of the object.
  final String name;

  /// The x coordinate of the object.
  final int x;

  /// The y coordinate of the object.
  final int y;

  /// The coordinates of the object.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Point<int> get coordinates => Point(x, y);

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RoomObjectReferenceToJson(this);
}

/// There are no [RoomObject]s to examine.
@JsonSerializable()
class NoRoomObjects extends AngstromEvent {
  /// Create an instance.
  const NoRoomObjects();

  /// Create an instance from a JSON object.
  factory NoRoomObjects.fromJson(final Map<String, dynamic> json) =>
      _$NoRoomObjectsFromJson(json);

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$NoRoomObjectsToJson(this);
}

/// Alert the client to a change of [Room].
@JsonSerializable()
class RoomId extends AngstromEvent {
  /// Create an instance.
  const RoomId({required this.roomId});

  /// Create an instance from a JSON object.
  factory RoomId.fromJson(final Map<String, dynamic> json) =>
      _$RoomIdFromJson(json);

  /// The ID of the new room.
  final String roomId;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RoomIdToJson(this);
}
