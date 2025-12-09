import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// The default function for examining a [RoomObject].
void defaultExamineRoomObject(
  final RoomObjectReference event,
  final AngstromEventHandlerState state,
) {
  final x =
      max(state.playerCoordinates.x, event.x) -
      min(state.playerCoordinates.x, event.x);
  final y =
      max(state.playerCoordinates.y, event.y) -
      min(state.playerCoordinates.y, event.y);
  final xDirection = event.x > state.playerCoordinates.x ? 'east' : 'west';
  final yDirection = event.y > state.playerCoordinates.y ? 'north' : 'south';
  final strings = <String>[];
  if (x != 0) {
    strings.add('$x $xDirection');
  }
  if (y != 0) {
    strings.add('$y $yDirection');
  }
  final text = strings.isEmpty ? 'here' : strings.join(', ');
  state.speakText(text: '${event.name}: $text', interrupt: true);
}

/// The default function for getting the [RoomObject] examination distance.
///
/// By default, this function simply returns 25.
int defaultGetExamineObjectDistance() => 25;

/// Get the default ordering for examining [RoomObject]s.
///
/// This function returns `RoomObjectOrdering.distance`.
RoomObjectOrdering defaultGetExamineObjectOrdering() =>
    RoomObjectOrdering.distance;

/// The default function for handling [NoRoomObjects] events.
void defaultNoRoomObjects(
  final NoRoomObjects event,
  final AngstromEventHandlerState state,
) => state.speakText(text: 'You see nothing here.', interrupt: true);

/// A complete game screen.
class GameScreen extends StatelessWidget {
  /// Create an instance.
  const GameScreen({
    required this.engine,
    required this.title,
    this.wallAttenuation = 0.4,
    this.wallFactor = 0.5,
    this.onExamineObject = defaultExamineRoomObject,
    this.getExamineObjectDistance = defaultGetExamineObjectDistance,
    this.getExamineObjectOrdering = defaultGetExamineObjectOrdering,
    this.onNoRoomObjects = defaultNoRoomObjects,
    this.getSound = defaultGetSound,
    super.key,
  });

  /// The engine to use.
  final AngstromEngine engine;

  /// The title of the game.
  final String title;

  /// How much to attenuate [RoomObject] ambiances by when there are walls in
  /// the way.
  final double wallAttenuation;

  /// How far to cutoff frequencies when occluding sounds for walls.
  final double wallFactor;

  /// The function to use to examine [RoomObject]s.
  final ExamineObjectCallback onExamineObject;

  /// The function to determine how far away objects can be examined.
  final ExamineObjectDistance getExamineObjectDistance;

  /// The function to call to get the order of examined objects.
  final ExamineObjectOrdering getExamineObjectOrdering;

  /// The function to call to handle the [NoRoomObjects] event.
  final NoRoomObjectsCallback onNoRoomObjects;

  /// The function to call to get a sound.
  final GetSound getSound;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final character = engine.playerCharacter;
    return SimpleScaffold(
      title: title,
      body: AngstromEventHandler(
        engine: engine,
        wallAttenuation: wallAttenuation,
        wallFactor: wallFactor,
        onExamineObject: onExamineObject,
        onNoRoomObjects: onNoRoomObjects,
        getSound: getSound,
        error: ErrorListView.withPositional,
        child: EngineTicker(
          engine: engine,
          child: GameControls(
            engine: engine,
            getExamineObjectDistance: getExamineObjectDistance,
            getExamineObjectOrdering: getExamineObjectOrdering,
            child: Text(character.name),
          ),
        ),
      ),
    );
  }
}
