// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_object_ambiance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomObjectAmbiance _$RoomObjectAmbianceFromJson(Map<String, dynamic> json) =>
    RoomObjectAmbiance(
      path: json['path'] as String,
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
      volume: (json['volume'] as num).toDouble(),
      ambianceMaxDistance: (json['ambianceMaxDistance'] as num).toInt(),
    );

Map<String, dynamic> _$RoomObjectAmbianceToJson(RoomObjectAmbiance instance) =>
    <String, dynamic>{
      'path': instance.path,
      'volume': instance.volume,
      'ambianceMaxDistance': instance.ambianceMaxDistance,
      'x': instance.x,
      'y': instance.y,
    };
