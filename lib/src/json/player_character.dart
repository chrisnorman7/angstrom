import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'player_character.g.dart';

/// A playing character in the game.
@JsonSerializable()
class PlayerCharacter {
  /// Create an instance.
  PlayerCharacter({
    required this.id,
    required this.name,
    required this.locationId,
    required this.x,
    required this.y,
    required this.statsMap,
  });

  /// Create an instance from a JSON object.
  factory PlayerCharacter.fromJson(final Map<String, dynamic> json) =>
      _$PlayerCharacterFromJson(json);

  /// The ID of this character.
  final String id;

  /// The name of this player.
  String name;

  /// The ID of the room where this player is located.
  String locationId;

  /// The x coordinate of this player.
  int x;

  /// The y coordinate of this player.
  int y;

  /// The coordinates of this player.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Point<int> get coordinates => Point(x, y);

  /// Set the [coordinates] for this player.
  set coordinates(final Point<int> value) {
    x = value.x;
    y = value.y;
  }

  /// The stats map for this player.
  final Map<String, dynamic> statsMap;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$PlayerCharacterToJson(this);
}
