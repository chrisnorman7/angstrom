// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_object_ambiance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomObjectAmbiance _$RoomObjectAmbianceFromJson(Map<String, dynamic> json) =>
    RoomObjectAmbiance(
      id: json['id'] as String,
      soundReference: SoundReference.fromJson(
        json['soundReference'] as Map<String, dynamic>,
      ),
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
      ambianceMaxDistance: (json['ambianceMaxDistance'] as num).toInt(),
    );

Map<String, dynamic> _$RoomObjectAmbianceToJson(RoomObjectAmbiance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'soundReference': instance.soundReference,
      'ambianceMaxDistance': instance.ambianceMaxDistance,
      'x': instance.x,
      'y': instance.y,
    };
