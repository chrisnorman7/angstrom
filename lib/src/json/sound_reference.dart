import 'package:json_annotation/json_annotation.dart';

part 'sound_reference.g.dart';

/// A reference to a sound.
@JsonSerializable()
class SoundReference {
  /// Create an instance.
  const SoundReference({required this.path, this.volume = 0.70});

  /// Create an instance from a JSON object.
  factory SoundReference.fromJson(final Map<String, dynamic> json) =>
      _$SoundReferenceFromJson(json);

  /// The path to the sound file.
  final String path;

  /// The volume of the sound.
  final double volume;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$SoundReferenceToJson(this);
}
