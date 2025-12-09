/// Various type definitions used throughout the engine.
library;

import 'package:angstrom/angstrom.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart'
    show Sound, SoundPosition;
import 'package:flutter_soloud/flutter_soloud.dart';

/// The type of a function which is called with an angstrom engine as its only
/// parameter.
typedef AngstromCallback = void Function(AngstromEngine engine);

/// The type of a function which converts a [SoundReference] path to a [Sound]
/// instance.
typedef GetSound =
    Sound Function({
      required SoundReference soundReference,
      required bool destroy,
      LoadMode loadMode,
      bool looping,
      Duration loopingStart,
      bool paused,
      SoundPosition position,
      double? volume,
      double relativePlaySpeed,
    });

/// The type of a function which examines an object.
typedef ExamineObjectCallback =
    void Function(
      RoomObjectReference objectReference,
      AngstromEventHandlerState state,
    );

/// The type of a function which will be used to handle [NoRoomObjects] events.
typedef NoRoomObjectsCallback =
    void Function(NoRoomObjects event, AngstromEventHandlerState state);
