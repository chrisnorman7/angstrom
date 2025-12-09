import 'dart:async';
import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:backstreets_widgets/typedefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:stts/stts.dart';

/// The default [GetSound] function.
Sound defaultGetSound({
  required final SoundReference soundReference,
  required final bool destroy,
  final LoadMode loadMode = LoadMode.memory,
  final bool looping = false,
  final Duration loopingStart = Duration.zero,
  final bool paused = false,
  final SoundPosition position = unpanned,
  final double? volume,
  final double relativePlaySpeed = 1.0,
}) => soundReference.path.asSound(
  destroy: destroy,
  loadMode: loadMode,
  looping: looping,
  position: position,
  volume: volume ?? soundReference.volume,
);

/// The main screen of the app.
class AngstromEventHandler extends StatefulWidget {
  /// Create an instance.
  const AngstromEventHandler({
    required this.engine,
    required this.wallAttenuation,
    required this.wallFactor,
    required this.onExamineObject,
    required this.onNoRoomObjects,
    required this.getSound,
    required this.error,
    required this.child,
    super.key,
  });

  /// The engine to use.
  final AngstromEngine engine;

  /// How much to attenuate [RoomObject] ambiances by when there are walls in
  /// the way.
  final double wallAttenuation;

  /// How far to cutoff frequencies when occluding sounds for walls.
  final double wallFactor;

  /// The function to call when examining an object.
  final ExamineObjectCallback onExamineObject;

  /// The function to call to handle the [NoRoomObjects] event.
  final NoRoomObjectsCallback onNoRoomObjects;

  /// The function to call to get a sound.
  final GetSound getSound;

  /// The widget to show errors.
  final ErrorWidgetCallback error;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Create state for this widget.
  @override
  AngstromEventHandlerState createState() => AngstromEventHandlerState();
}

/// State for [AngstromEventHandler].
class AngstromEventHandlerState extends State<AngstromEventHandler> {
  /// The stream controller for listening for engine events.
  late final StreamSubscription<AngstromEvent> _listener;

  /// The TTS system to use.
  late final Tts _tts;

  /// The ID of the current room.
  String? _roomId;

  /// The currently-playing music.
  PlayingSound? _music;

  /// The currently-playing room surface ambiance.
  PlayingSound? _roomSurfaceAmbiance;

  /// The coordinates of the player.
  Point<int>? _playerCoordinates;

  /// The coordinates of the player.
  ///
  /// Throws [StateError] if the coordinates have not been set yet.
  Point<int> get playerCoordinates {
    final c = _playerCoordinates;
    if (c == null) {
      throw StateError('The player coordinates have not been set yet.');
    }
    return c;
  }

  /// The time that room object ambiances were last updated.
  late int _roomObjectAmbiancesLastUpdate;

  /// The current room object ambiances.
  late final List<RoomObjectAmbiance> _roomObjectAmbiances;

  /// The sound handles for playing room object ambiances.
  late final List<AudioSourceAndHandle?> _roomObjectAmbianceSoundHandles;

  /// The walls in the current room.
  late final List<Point<int>> _wallCoordinates;

  /// The current move interval.
  late Duration _moveInterval;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _tts = Tts();
    _roomObjectAmbiancesLastUpdate = 0;
    _roomObjectAmbiances = [];
    _roomObjectAmbianceSoundHandles = [];
    _wallCoordinates = [];
    _listener = widget.engine.events.listen(handleEvent);
  }

  /// Stop all room object ambiances.
  void stopRoomObjectAmbiances() {
    _roomObjectAmbiances.clear();
    for (final handle in _roomObjectAmbianceSoundHandles) {
      handle?.handle?.stop(fadeOutTime: widget.engine.musicFadeOut);
    }
    _roomObjectAmbianceSoundHandles.clear();
  }

  /// Update room object ambiances.
  Future<void> updateRoomObjectAmbiances() async {
    final timestamp = _roomObjectAmbiancesLastUpdate;
    assert(
      _roomObjectAmbianceSoundHandles.length == _roomObjectAmbiances.length,
      // ignore: lines_longer_than_80_chars
      'The list of room object ambiances and their associated handles are different lengths. This is a bug.',
    );
    for (var i = 0; i < _roomObjectAmbianceSoundHandles.length; i++) {
      if (_roomObjectAmbiancesLastUpdate != timestamp) {
        break;
      }
      final ambiance = _roomObjectAmbiances[i];
      final handle = _roomObjectAmbianceSoundHandles[i];
      final coordinates = ambiance.coordinates;
      final distance = playerCoordinates.distanceTo(coordinates);
      if (distance > ambiance.ambianceMaxDistance) {
        unawaited(handle?.handle?.stop());
        _roomObjectAmbianceSoundHandles[i] = null;
      } else {
        final walls = _countOccludingWalls(playerCoordinates, coordinates);
        final newVolume = occludedVolume(
          distance: distance,
          fullVolume: ambiance.volume,
          occludingWalls: walls,
          maxDistance: ambiance.ambianceMaxDistance,
        );
        if (handle == null) {
          late final AudioSource source;
          final h = await context.playSound(
            widget.getSound(
              soundReference: ambiance.path.asSoundReference(volume: newVolume),
              destroy: false,
              loadMode: LoadMode.disk,
              looping: true,
              position: SoundPosition3d(
                coordinates.x.toDouble(),
                0,
                coordinates.y.toDouble(),
              ),
            ),
            onSourceLoad: (final s) {
              source = s;
            },
          );
          h.setMinMaxDistance(0, ambiance.ambianceMaxDistance.toDouble());
          maybeFilterSource(source: source, handle: h, numberOfWalls: walls);
          if (mounted && _roomObjectAmbiancesLastUpdate == timestamp) {
            unawaited(_roomObjectAmbianceSoundHandles[i]?.handle?.stop());
            _roomObjectAmbianceSoundHandles[i] = AudioSourceAndHandle(
              source: source,
              handle: h,
            );
          } else {
            return unawaited(h.stop());
          }
        } else {
          handle.handle.volume.fade(newVolume, _moveInterval);
          maybeFilterSource(
            source: handle.source,
            handle: handle.handle,
            numberOfWalls: walls,
          );
        }
      }
    }
  }

  /// Maybe filter the given [source] and [handle].
  void maybeFilterSource({
    required final AudioSource source,
    required final SoundHandle handle,
    required final int numberOfWalls,
  }) {
    final biquadFilter = source.filters.biquadFilter;

    if (!biquadFilter.isActive) {
      biquadFilter.activate();
    }

    // Query the valid cutoff range from SoLoud
    final minCutoff = biquadFilter.queryFrequency.min; // e.g. ~10–600 Hz
    final maxCutoff = biquadFilter.queryFrequency.max; // e.g. ~8000–22000 Hz

    // -------------------------
    // 1) Base occlusion curve
    // -------------------------
    // Simple, predictable, stable:
    //   0 walls → maxCutoff
    //   1 wall  → maxCutoff * 0.5
    //   2 walls → maxCutoff * 0.25
    //   3 walls → maxCutoff * 0.125
    //
    // No exponential distance madness.
    //
    var cutoff = maxCutoff * pow(widget.wallFactor, numberOfWalls).toDouble();

    // -------------------------
    // 2) Clamp to safe range
    // -------------------------
    cutoff = cutoff.clamp(minCutoff, maxCutoff);

    // Debug if you want:
    // print('occluded cutoff = $cutoff');

    // -------------------------
    // 3) Apply to filter
    // -------------------------
    biquadFilter
        .frequency(soundHandle: handle)
        .fadeFilterParameter(to: cutoff, time: _moveInterval);
  }

  /// Speak some [text].
  Future<void> speakText({
    required final String text,
    required final bool interrupt,
  }) async {
    if (interrupt) {
      await _tts.stop();
    }
    await _tts.start(text);
  }

  /// Handle a single [event].
  Future<void> handleEvent(final AngstromEvent event) async {
    switch (event) {
      case SpeakEvent():
        unawaited(speakText(text: event.text, interrupt: event.interrupt));
        break;
      case PlayerCoordinates():
        _playerCoordinates = event.coordinates;
        SoLoud.instance.set3dListenerPosition(
          playerCoordinates.x.toDouble(),
          0.0,
          playerCoordinates.y.toDouble(),
        );
        unawaited(updateRoomObjectAmbiances());
        break;
      case PlayerFootstepSound():
        final soundReference = event.footstepSounds.randomElement();
        final sound = widget.getSound(
          soundReference: soundReference.asSoundReference(),
          destroy: true,
        );
        if (mounted) {
          unawaited(context.playSound(sound));
        }
        break;
      case PlayMusic():
        final reference = event.music;
        final oldMusic = _music;
        if (reference == null) {
          await oldMusic?.handle?.stop(fadeOutTime: widget.engine.musicFadeOut);
        } else if (oldMusic == null) {
          final sound = widget.getSound(
            soundReference: reference,
            destroy: false,
            loadMode: LoadMode.disk,
            looping: true,
            volume: 0,
          );
          final handle = await context.playSound(sound);
          if (mounted) {
            _music = PlayingSound(reference: reference, handle: handle);
            handle.volume.fade(reference.volume, widget.engine.musicFadeIn);
          } else {
            unawaited(handle.stop());
          }
        } else {
          // Both reference and old music are non null.
          if (reference.path == oldMusic.reference.path) {
            final volume = reference.volume;
            final oldVolume = oldMusic.reference.volume;
            oldMusic.handle.volume.fade(
              volume,
              volume > oldVolume
                  ? widget.engine.musicFadeIn
                  : widget.engine.musicFadeOut,
            );
          } else {
            _music = null;
            unawaited(
              oldMusic.handle.stop(fadeOutTime: widget.engine.musicFadeOut),
            );
            final handle = await context.playSound(
              widget.getSound(
                soundReference: reference,
                destroy: false,
                loadMode: LoadMode.disk,
                looping: true,
                volume: 0,
              ),
            );
            if (mounted) {
              _music = PlayingSound(reference: reference, handle: handle);
              handle.volume.fade(reference.volume, widget.engine.musicFadeIn);
            } else {
              unawaited(handle.stop());
            }
          }
        }
        break;
      case PlayerMoving():
        // We don't care about this one.
        break;
      case InterfaceSound():
        final soundReference = event.soundReference;
        unawaited(
          context.playSound(
            widget.getSound(soundReference: soundReference, destroy: true),
          ),
        );
        break;
      case RoomObjectAmbiances():
        _roomObjectAmbiancesLastUpdate = DateTime.now().millisecondsSinceEpoch;
        stopRoomObjectAmbiances();
        _roomObjectAmbiances.addAll(event.ambiances);
        _roomObjectAmbianceSoundHandles.addAll(
          List.generate(event.ambiances.length, (_) => null),
        );
        unawaited(updateRoomObjectAmbiances());
        break;
      case RoomSurfaceAmbiance():
        final oldAmbiance = _roomSurfaceAmbiance;
        final ambiance = event.ambiance;
        if (ambiance == null) {
          unawaited(
            oldAmbiance?.handle?.stop(fadeOutTime: widget.engine.musicFadeOut),
          );
          _roomSurfaceAmbiance = null;
        } else if (oldAmbiance == null) {
          final handle = await context.playSound(
            widget.getSound(
              soundReference: ambiance.path.asSoundReference(volume: 0.0),
              destroy: false,
              loadMode: LoadMode.disk,
              looping: true,
            ),
          );
          handle.volume.fade(ambiance.volume, widget.engine.musicFadeIn);
          unawaited(_roomSurfaceAmbiance?.handle?.stop());
          _roomSurfaceAmbiance = PlayingSound(
            reference: ambiance,
            handle: handle,
          );
        } else {
          // Old and new ambiances are both not null.
          if (oldAmbiance.reference.path == ambiance.path) {
            oldAmbiance.handle.volume.fade(
              ambiance.volume,
              ambiance.volume > oldAmbiance.reference.volume
                  ? widget.engine.musicFadeIn
                  : widget.engine.musicFadeOut,
            );
          } else {
            _roomSurfaceAmbiance = null;
            unawaited(
              oldAmbiance.handle.stop(fadeOutTime: widget.engine.musicFadeOut),
            );
            final handle = await context.playSound(
              widget.getSound(
                soundReference: ambiance.path.asSoundReference(volume: 0.0),
                destroy: false,
                loadMode: LoadMode.disk,
                looping: true,
              ),
            );
            handle.volume.fade(ambiance.volume, widget.engine.musicFadeIn);
            unawaited(_roomSurfaceAmbiance?.handle?.stop());
            _roomSurfaceAmbiance = PlayingSound(
              reference: ambiance,
              handle: handle,
            );
          }
        }
        break;
      case RoomWalls():
        _wallCoordinates.clear();
        _wallCoordinates.addAll(
          event.walls.map(
            (final objectCoordinates) => objectCoordinates.coordinates,
          ),
        );
        break;
      case MoveInterval():
        _moveInterval = event.moveInterval;
        break;
      case Play3dSound():
        final point = Point(event.x, event.z).floor();
        final distance = playerCoordinates.distanceTo(point);
        if (distance <= event.maxDistance) {
          final reference = event.reference;
          final walls = _countOccludingWalls(playerCoordinates, point);
          late final AudioSource source;
          final handle = await context.playSound(
            widget.getSound(
              soundReference: reference.path.asSoundReference(
                volume: occludedVolume(
                  distance: distance,
                  fullVolume: reference.volume,
                  occludingWalls: walls,
                  maxDistance: event.maxDistance,
                ),
              ),
              destroy: true,
              position: SoundPosition3d(
                event.x,
                event.z, // Take into account default listener orientation.
                event.y,
                // Take into account the default listener orientation.
              ),
            ),
            onSourceLoad: (final s) {
              source = s;
            },
          );
          maybeFilterSource(
            source: source,
            handle: handle,
            numberOfWalls: walls,
          );
        }
        break;
      case RoomObjectReference():
        widget.onExamineObject(event, this);
        break;
      case NoRoomObjects():
        widget.onNoRoomObjects(event, this);
        break;
      case RoomId():
        setState(() {
          _roomId = event.roomId;
        });
        break;
    }
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    _listener.cancel();
    _tts.stop();
    _music?.handle?.stop(fadeOutTime: widget.engine.musicFadeOut);
    stopRoomObjectAmbiances();
    _roomSurfaceAmbiance?.handle?.stop(fadeOutTime: widget.engine.musicFadeOut);
  }

  /// Calculate the volume of a sound [distance] units away, using an inverse
  /// square formula.
  double inverseSquareVolume(
    final double distance,
    final double fullVolume,
    final int maxDistance,
  ) {
    final d = distance / maxDistance;
    final rolloff = 1.0 / (1.0 + (d * d * 10));
    return fullVolume * rolloff;
  }

  /// Return [inverseSquareVolume] after the sound has passed through
  /// [occludingWalls] walls.
  double occludedVolume({
    required final double distance,
    required final double fullVolume,
    required final int occludingWalls,
    required final int maxDistance,
  }) {
    if (distance > maxDistance) {
      return 0.0;
    }

    final base = inverseSquareVolume(distance, fullVolume, maxDistance);
    final wallRolloff = pow(widget.wallAttenuation, occludingWalls).toDouble();
    return base * wallRolloff;
  }

  /// A function which returns the number of occluding walls between [a] and
  /// [b].
  int _countOccludingWalls(final Point<int> a, final Point<int> b) {
    var count = 0;

    for (final p in a.bresenham(b)) {
      // Ignore endpoints
      if (p == a || p == b) {
        continue;
      }
      if (_isWall(p)) {
        count++;
      }
    }

    return count;
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final List<Sound> contactSounds;
    if (_roomId == null) {
      contactSounds = [];
    } else {
      final room = widget.engine.room;
      final surfaces = room.surfaces;
      contactSounds = [
        for (final surface in surfaces) ...surface.contactSounds,
      ].asSoundList(destroy: true);
      // ignore: avoid_catching_errors
    }
    return LoadSounds(
      sounds: contactSounds,
      error: widget.error,
      loading: () => widget.child,
      child: widget.child,
    );
  }

  /// Returns `true` if there is a wall at [p].
  bool _isWall(final Point<int> p) => _wallCoordinates.contains(p);
}
