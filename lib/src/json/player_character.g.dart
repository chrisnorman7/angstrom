// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerCharacter _$PlayerCharacterFromJson(Map<String, dynamic> json) =>
    PlayerCharacter(
      id: json['id'] as String,
      name: json['name'] as String,
      locationId: json['locationId'] as String,
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
      statsMap: json['statsMap'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PlayerCharacterToJson(PlayerCharacter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'locationId': instance.locationId,
      'x': instance.x,
      'y': instance.y,
      'statsMap': instance.statsMap,
    };
