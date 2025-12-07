// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SoundReference _$SoundReferenceFromJson(Map<String, dynamic> json) =>
    SoundReference(
      path: json['path'] as String,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.70,
    );

Map<String, dynamic> _$SoundReferenceToJson(SoundReference instance) =>
    <String, dynamic>{'path': instance.path, 'volume': instance.volume};
