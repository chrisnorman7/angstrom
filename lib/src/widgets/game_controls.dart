import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';

/// The type of a function which returns a suitable distance for examining
/// [RoomObject]s.
typedef ExamineObjectDistance = int Function();

/// The type of a function which returns the ordering for examining
/// [RoomObject]s.
typedef ExamineObjectOrdering = RoomObjectOrdering Function();

/// A screen which provides controls to control [engine].
class GameControls extends StatefulWidget {
  /// Create an instance.
  const GameControls({
    required this.engine,
    required this.getExamineObjectDistance,
    required this.getExamineObjectOrdering,
    required this.child,
    this.gameShortcutsBuilder,
    super.key,
  });

  /// The engine to use.
  final AngstromEngine engine;

  /// The function to determine how far away objects can be examined.
  final ExamineObjectDistance getExamineObjectDistance;

  /// The function to call to get the order of examined objects.
  final ExamineObjectOrdering getExamineObjectOrdering;

  /// The widget below this widget in the tree.
  final Widget child;

  /// The function to call to get the final game shortcuts.
  final GameShortcutsBuilder? gameShortcutsBuilder;

  /// Create state for this widget.
  @override
  GameControlsState createState() => GameControlsState();
}

/// State for [GameControls].
class GameControlsState extends State<GameControls> {
  /// The angstrom engine to use.
  AngstromEngine get engine => widget.engine;

  /// The player's coordinates in the current room.
  Point<int> get coordinates => engine.playerCoordinates;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final defaultShortcuts = <GameShortcut>[
      GameShortcut(
        title: 'Speak current coordinates',
        shortcut: GameShortcutsShortcut.keyC,
        onStart: (final innerContext) =>
            engine.speak('${coordinates.x}, ${coordinates.y}'),
      ),
      GameShortcut(
        title: 'Activate the current coordinates',
        shortcut: GameShortcutsShortcut.enter,
        onStart: (final innerContext) => engine.activate(),
      ),
      GameShortcut(
        title: 'Walk north',
        shortcut: GameShortcutsShortcut.keyW,
        onStart: (final innerContext) =>
            engine.startPlayerMoving(FacingDirection.north),
        onStop: (_) => engine.stopPlayerMoving(),
      ),
      GameShortcut(
        title: 'Walk south',
        shortcut: GameShortcutsShortcut.keyS,
        onStart: (final innerContext) =>
            engine.startPlayerMoving(FacingDirection.south),
        onStop: (_) => engine.stopPlayerMoving(),
      ),
      GameShortcut(
        title: 'Walk west',
        shortcut: GameShortcutsShortcut.keyA,
        onStart: (final innerContext) =>
            engine.startPlayerMoving(FacingDirection.west),
        onStop: (_) => engine.stopPlayerMoving(),
      ),
      GameShortcut(
        title: 'Walk east',
        shortcut: GameShortcutsShortcut.keyD,
        onStart: (final innerContext) =>
            engine.startPlayerMoving(FacingDirection.east),
        onStop: (_) => engine.stopPlayerMoving(),
      ),
      GameShortcut(
        title: 'Examine next object',
        shortcut: GameShortcutsShortcut.bracketRight,
        onStart: (final innerContext) => engine.examineNextObject(
          widget.getExamineObjectDistance(),
          widget.getExamineObjectOrdering(),
        ),
      ),
      GameShortcut(
        title: 'Examine previous objects',
        shortcut: GameShortcutsShortcut.bracketLeft,
        onStart: (final innerContext) => engine.examinePreviousObject(
          widget.getExamineObjectDistance(),
          widget.getExamineObjectOrdering(),
        ),
      ),
      GameShortcut(
        title: 'Show shortcut help',
        shortcut: GameShortcutsShortcut.slash,
        shiftKey: true,
        onStart: (final innerContext) async {
          engine.pause();
          await innerContext.pushWidgetBuilder(
            (_) => const GameShortcutsHelpScreen(),
          );
          engine.unpause();
        },
      ),
    ];
    return GameShortcuts(
      shortcuts:
          widget.gameShortcutsBuilder?.call(context, defaultShortcuts) ??
          defaultShortcuts,
      child: widget.child,
    );
  }
}
