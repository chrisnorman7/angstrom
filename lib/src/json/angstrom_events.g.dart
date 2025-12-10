// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'angstrom_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeakEvent _$SpeakEventFromJson(Map<String, dynamic> json) => SpeakEvent(
  text: json['text'] as String,
  interrupt: json['interrupt'] as bool? ?? true,
);

Map<String, dynamic> _$SpeakEventToJson(SpeakEvent instance) =>
    <String, dynamic>{'text': instance.text, 'interrupt': instance.interrupt};

PlayerCoordinates _$PlayerCoordinatesFromJson(Map<String, dynamic> json) =>
    PlayerCoordinates(
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
    );

Map<String, dynamic> _$PlayerCoordinatesToJson(PlayerCoordinates instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y};

PlayerFootstepSound _$PlayerFootstepSoundFromJson(Map<String, dynamic> json) =>
    PlayerFootstepSound(
      footstepSounds: (json['footstepSounds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      volume: (json['volume'] as num).toDouble(),
    );

Map<String, dynamic> _$PlayerFootstepSoundToJson(
  PlayerFootstepSound instance,
) => <String, dynamic>{
  'footstepSounds': instance.footstepSounds,
  'volume': instance.volume,
};

PlayMusic _$PlayMusicFromJson(Map<String, dynamic> json) => PlayMusic(
  music: json['music'] == null
      ? null
      : SoundReference.fromJson(json['music'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlayMusicToJson(PlayMusic instance) => <String, dynamic>{
  'music': instance.music,
};

PlayerMoving _$PlayerMovingFromJson(Map<String, dynamic> json) => PlayerMoving(
  direction: $enumDecodeNullable(_$FacingDirectionEnumMap, json['direction']),
);

Map<String, dynamic> _$PlayerMovingToJson(PlayerMoving instance) =>
    <String, dynamic>{
      'direction': _$FacingDirectionEnumMap[instance.direction],
    };

const _$FacingDirectionEnumMap = {
  FacingDirection.north: 'north',
  FacingDirection.east: 'east',
  FacingDirection.south: 'south',
  FacingDirection.west: 'west',
};

InterfaceSound _$InterfaceSoundFromJson(Map<String, dynamic> json) =>
    InterfaceSound(
      soundReference: SoundReference.fromJson(
        json['soundReference'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$InterfaceSoundToJson(InterfaceSound instance) =>
    <String, dynamic>{'soundReference': instance.soundReference};

RoomObjectAmbiances _$RoomObjectAmbiancesFromJson(Map<String, dynamic> json) =>
    RoomObjectAmbiances(
      ambiances: (json['ambiances'] as List<dynamic>)
          .map((e) => RoomObjectAmbiance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoomObjectAmbiancesToJson(
  RoomObjectAmbiances instance,
) => <String, dynamic>{'ambiances': instance.ambiances};

RoomSurfaceAmbiance _$RoomSurfaceAmbianceFromJson(Map<String, dynamic> json) =>
    RoomSurfaceAmbiance(
      ambiance: json['ambiance'] == null
          ? null
          : SoundReference.fromJson(json['ambiance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoomSurfaceAmbianceToJson(
  RoomSurfaceAmbiance instance,
) => <String, dynamic>{'ambiance': instance.ambiance};

RoomWalls _$RoomWallsFromJson(Map<String, dynamic> json) => RoomWalls(
  walls: (json['walls'] as List<dynamic>)
      .map((e) => ObjectCoordinates.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoomWallsToJson(RoomWalls instance) => <String, dynamic>{
  'walls': instance.walls,
};

MoveInterval _$MoveIntervalFromJson(Map<String, dynamic> json) => MoveInterval(
  moveInterval: Duration(microseconds: (json['moveInterval'] as num).toInt()),
);

Map<String, dynamic> _$MoveIntervalToJson(MoveInterval instance) =>
    <String, dynamic>{'moveInterval': instance.moveInterval.inMicroseconds};

Play3dSound _$Play3dSoundFromJson(Map<String, dynamic> json) => Play3dSound(
  reference: SoundReference.fromJson(json['reference'] as Map<String, dynamic>),
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  z: (json['z'] as num).toDouble(),
  maxDistance: (json['maxDistance'] as num).toInt(),
);

Map<String, dynamic> _$Play3dSoundToJson(Play3dSound instance) =>
    <String, dynamic>{
      'reference': instance.reference,
      'x': instance.x,
      'y': instance.y,
      'z': instance.z,
      'maxDistance': instance.maxDistance,
    };

RoomObjectReference _$RoomObjectReferenceFromJson(Map<String, dynamic> json) =>
    RoomObjectReference(
      name: json['name'] as String,
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
    );

Map<String, dynamic> _$RoomObjectReferenceToJson(
  RoomObjectReference instance,
) => <String, dynamic>{'name': instance.name, 'x': instance.x, 'y': instance.y};

NoRoomObjects _$NoRoomObjectsFromJson(Map<String, dynamic> json) =>
    NoRoomObjects();

Map<String, dynamic> _$NoRoomObjectsToJson(NoRoomObjects instance) =>
    <String, dynamic>{};

RoomId _$RoomIdFromJson(Map<String, dynamic> json) =>
    RoomId(roomId: json['roomId'] as String);

Map<String, dynamic> _$RoomIdToJson(RoomId instance) => <String, dynamic>{
  'roomId': instance.roomId,
};

MoveRoomObject _$MoveRoomObjectFromJson(Map<String, dynamic> json) =>
    MoveRoomObject(
      id: json['id'] as String,
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
    );

Map<String, dynamic> _$MoveRoomObjectToJson(MoveRoomObject instance) =>
    <String, dynamic>{'id': instance.id, 'x': instance.x, 'y': instance.y};
