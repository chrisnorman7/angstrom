import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:angstrom/angstrom.dart';
import 'package:meta/meta.dart';

/// The main engine class to use.
abstract class AngstromEngine {
  /// Create an instance.
  AngstromEngine({
    required this.playerCharacter,
    this.musicFadeIn = const Duration(milliseconds: 500),
    this.musicFadeOut = const Duration(seconds: 3),
  }) : _tiles = HashMap(),
       _roomObjects = HashMap(),
       _playerLastMoved = 0,
       _controller = StreamController(),
       tasks = [],
       _gameMilliseconds = 0,
       _paused = false,
       _initialised = false;

  /// The player character to use.
  final PlayerCharacter playerCharacter;

  /// The time it takes music to fade in.
  final Duration musicFadeIn;

  /// The time it takes for music to fade out.
  final Duration musicFadeOut;

  /// The room where the player is located.
  Room? _room;

  /// The room where the player is located.
  Room get room {
    final r = _room;
    if (r != null) {
      return r;
    }
    throw StateError('`_room` has not been set yet.');
  }

  /// The tiles in [room].
  final HashMap<Point<int>, RoomSurface> _tiles;

  /// The objects in the [room].
  final HashMap<Point<int>, RoomObject> _roomObjects;

  /// The current surface the player is on.
  RoomSurface? _currentSurface;

  /// The surface which the player is currently standing on.
  RoomSurface? get currentSurface => _currentSurface;

  /// The coordinates where the player is located in [room].
  Point<int> get playerCoordinates => playerCharacter.coordinates;

  /// Set the coordinates for the [playerCharacter].
  set playerCoordinates(final Point<int> value) =>
      playerCharacter.coordinates = value;

  /// The direction the player is facing.
  FacingDirection? _playerDirection;

  /// Convert room [id] to a [Room] instance.
  FutureOr<Room> buildRoom(final String id);

  /// The last time the player moved.
  int _playerLastMoved;

  /// The milliseconds when the player can next move.
  int get playerNextMove {
    final surface = getRoomSurface(playerCoordinates)!;
    return _playerLastMoved - surface.moveInterval.inMilliseconds;
  }

  /// The stream controller for emitted events.
  final StreamController<AngstromEvent> _controller;

  /// The stream of events to be emitted by the engine.
  Stream<AngstromEvent> get events => _controller.stream;

  /// The tasks which will be run.
  @visibleForTesting
  final List<AngstromTask> tasks;

  /// The engine's internal clock.
  int _gameMilliseconds;

  /// Whether the game is paused or not.
  bool _paused;

  /// Whether [init] has been called.
  bool _initialised;

  /// Whether or not the engine has been initialised.
  bool get initialised => _initialised;

  /// The index of the last examined [RoomObject].
  int? _lastObjectIndex;

  /// Returns `true` of the game is paused.
  bool get isPaused => _paused;

  /// Get the [RoomSurface] at the given [coordinates].
  RoomSurface? getRoomSurface(final Point<int> coordinates) =>
      _tiles[coordinates];

  /// Get the [RoomObject] at the given [coordinates].
  RoomObject? getRoomObject(final Point<int> coordinates) =>
      _roomObjects[coordinates];

  /// Prepare the engine.
  ///
  /// The [init] method will set the [room] and other properties. It should be
  /// called after the [events] stream has been subscribed to, and before the
  /// engine has been ticked.
  ///
  /// If [init] is called more than once, [StateError] will be thrown.
  void init() {
    if (_initialised) {
      throw StateError('The engine has already been initialised.');
    }
    teleportPlayer(playerCharacter.locationId, playerCharacter.coordinates);
    _initialised = true;
  }

  /// Start the player moving.
  void startPlayerMoving(final FacingDirection direction) {
    _playerDirection = direction;
    _controller.add(PlayerMoving(direction: direction));
  }

  /// Stop the player moving.
  void stopPlayerMoving() {
    if (_playerDirection != null) {
      _playerDirection = null;
      _controller.add(const PlayerMoving());
    }
  }

  /// Move the player.
  void _movePlayer() {
    final direction = _playerDirection;
    if (direction == null) {
      return;
    }
    final newCoordinates = playerCoordinates.pointInDirection(direction);
    final newSurface = getRoomSurface(newCoordinates);
    if (newSurface == null) {
      return stopPlayerMoving();
    }
    final oldSurface = _currentSurface;
    if (oldSurface == null) {
      return;
    }
    _controller.add(
      PlayerFootstepSound(
        footstepSounds: newSurface.contactSounds,
        volume: newSurface.contactSoundsVolume,
      ),
    );
    if (newSurface != oldSurface) {
      newSurface.onEnter?.call(this);
      if (!newSurface.isWall) {
        oldSurface.onExit?.call(this);
        _controller.add(RoomSurfaceAmbiance(ambiance: newSurface.ambiance));
        _currentSurface = newSurface;
        _controller.add(MoveInterval(moveInterval: newSurface.moveInterval));
      } else {
        return stopPlayerMoving();
      }
    }
    final oldObject = getRoomObject(playerCoordinates);
    _setPlayerCoordinates(newCoordinates);
    oldObject?.onLeave?.call(this);
    newSurface.onMove?.call(this);
    getRoomObject(newCoordinates)?.onApproach?.call(this);
  }

  /// Set the [coordinates] for the [playerCharacter].
  void _setPlayerCoordinates(final Point<int> coordinates) {
    playerCoordinates = coordinates;
    playerCharacter.coordinates = coordinates;
    _controller.add(PlayerCoordinates(x: coordinates.x, y: coordinates.y));
  }

  /// The code that runs every tick.
  ///
  /// The [delta] argument should be the number of milliseconds since the last
  /// call to [onTick].
  ///
  /// The [onTick] method will return `true` if the tick is successful, and
  /// `false` if [isPaused] is `true`.
  bool onTick(final int delta) {
    if (_paused) {
      return false;
    }
    _gameMilliseconds += delta;
    _tickPlayerMovement();
    _tickTasks();
    return true;
  }

  /// Tick player movement.
  void _tickPlayerMovement() {
    final surface = _currentSurface;
    if (surface == null) {
      return;
    }
    if (_playerDirection != null &&
        (_gameMilliseconds - _playerLastMoved) >=
            surface.moveInterval.inMilliseconds) {
      _playerLastMoved = _gameMilliseconds;
      _movePlayer();
    }
  }

  /// Tick the running [tasks].
  void _tickTasks() {
    final completedTasks = <AngstromTask>[];
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      if (task.milliseconds <= _gameMilliseconds) {
        completedTasks.add(task);
        task.callback(this);
      }
    }
    completedTasks.forEach(tasks.remove);
  }

  /// Speak some [text].
  void speak(final String text) => _controller.add(SpeakEvent(text: text));

  /// Move the player to new [coordinates].
  void movePlayer(final Point<int> coordinates) {
    playerCharacter.coordinates = coordinates;
    playerCoordinates = coordinates;
    _controller
      ..add(PlayerCoordinates(x: coordinates.x, y: coordinates.y))
      ..add(
        MoveInterval(
          moveInterval: _currentSurface?.moveInterval ?? Duration.zero,
        ),
      )
      ..add(RoomSurfaceAmbiance(ambiance: _currentSurface?.ambiance));
  }

  /// Move the player to a new room.
  Future<void> teleportPlayer(
    final String destinationId,
    final Point<int> coordinates,
  ) async {
    if (_room != null && room.id != destinationId) {
      room.onLeave(this);
      _lastObjectIndex = null;
    }
    playerCharacter.locationId = destinationId;
    final r = await buildRoom(destinationId);
    _room = r;
    _tiles.clear();
    for (final surface in r.surfaces) {
      for (final point in surface.points) {
        _tiles[point] = surface;
      }
    }
    _roomObjects.clear();
    for (final object in r.objects) {
      _roomObjects[object.coordinates] = object;
    }
    _currentSurface = getRoomSurface(coordinates);
    movePlayer(coordinates);
    _controller
      ..add(
        RoomObjectAmbiances(
          ambiances: [
            ...room.objects
                .where((final object) => object.ambiance != null)
                .map((final object) {
                  final ambiance = object.ambiance!;
                  return RoomObjectAmbiance(
                    id: object.id,
                    soundReference: ambiance,
                    x: object.coordinates.x,
                    y: object.coordinates.y,
                    ambianceMaxDistance: object.ambianceMaxDistance,
                  );
                }),
          ],
        ),
      )
      ..add(
        RoomWalls(
          walls: List<ObjectCoordinates>.from(
            _tiles.entries.where((final entry) => entry.value.isWall).map((
              final entry,
            ) {
              final point = entry.key;
              return ObjectCoordinates(point.x, point.y);
            }),
          ),
        ),
      )
      ..add(PlayMusic(music: room.music))
      ..add(RoomId(roomId: r.id));
    room.onEnter(this);
    _currentSurface?.onEnter?.call(this);
  }

  /// Play [music].
  void playMusic(final SoundReference music) =>
      _controller.add(PlayMusic(music: music));

  /// Stop music.
  void stopMusic() => _controller.add(const PlayMusic());

  /// Play an interface sound.
  void playInterfaceSound(final SoundReference soundReference) =>
      _controller.add(InterfaceSound(soundReference: soundReference));

  /// Activate the current coordinates.
  ///
  /// When you call [activate], the engine looks for a [RoomObject] at
  /// [playerCoordinates],, and calls its `onActivate` method.
  void activate() {
    getRoomObject(playerCoordinates)?.onActivate?.call(this);
  }

  /// Tell the client to play a 3d sound.
  void play3dSound(
    final SoundReference reference, {
    final double x = 0.0,
    final double y = 0.0,
    final double z = 0.0,
    final int maxDistance = 30,
  }) => _controller.add(
    Play3dSound(
      reference: reference,
      x: x,
      y: y,
      z: z,
      maxDistance: maxDistance,
    ),
  );

  /// Register a task with the [tasks] list.
  void scheduleTask(final Duration delay, final AngstromCallback callback) {
    final task = AngstromTask(
      milliseconds: _gameMilliseconds + delay.inMilliseconds,
      callback: callback,
    );
    tasks.add(task);
  }

  /// Schedule a repeating task.
  ///
  /// Every time [callback] returns `true`, it will be scheduled again using
  /// [getDelay].
  void scheduleRepeatingTask(
    final Duration Function() getDelay,
    final bool Function(AngstromEngine engine) callback,
  ) {
    void cb(final AngstromEngine engine) {
      if (callback(this)) {
        scheduleTask(getDelay(), cb);
      }
    }

    scheduleTask(getDelay(), cb);
  }

  /// Pause the game.
  void pause() {
    if (_paused) {
      throw StateError('The game is already paused.');
    }
    _paused = true;
  }

  /// Resume (unpause) the game.
  void unpause() {
    if (!_paused) {
      throw StateError('The game is not paused.');
    }
    _paused = false;
  }

  /// Used by [examineNextObject] and [examinePreviousObject] to examine objects
  /// within [distance] of [startCoordinates] (usually [playerCoordinates]).
  ///
  /// The [direction] argument specifies which way to go.
  void examineObject({
    required final int direction,
    required final int distance,
    required final Point<int> startCoordinates,
    required final RoomObjectOrdering ordering,
  }) {
    final objects =
        _roomObjects.entries
            .where((final entry) {
              final coordinates = entry.key;
              return startCoordinates.distanceTo(coordinates) <= distance;
            })
            .map((final entry) => entry.value)
            .toList()
          ..sort((final a, final b) {
            switch (ordering) {
              case RoomObjectOrdering.name:
                return a.name.toLowerCase().compareTo(b.name.toLowerCase());
              case RoomObjectOrdering.distance:
                return playerCoordinates
                    .distanceTo(a.coordinates)
                    .compareTo(playerCoordinates.distanceTo(b.coordinates));
            }
          });
    if (objects.isEmpty) {
      return _controller.add(const NoRoomObjects());
    }
    final lastIndex = _lastObjectIndex;
    final RoomObject object;
    if (lastIndex == null || lastIndex >= objects.length) {
      object = objects.first;
    } else {
      final index = (lastIndex + direction) % objects.length;
      object = objects[index];
    }
    _controller.add(
      RoomObjectReference(
        name: object.name,
        x: object.coordinates.x,
        y: object.coordinates.y,
      ),
    );
  }

  /// Examine the next object within [distance].
  void examineNextObject(
    final int distance,
    final RoomObjectOrdering ordering,
  ) => examineObject(
    direction: 1,
    distance: distance,
    startCoordinates: playerCoordinates,
    ordering: ordering,
  );

  /// Examine the previous object.
  void examinePreviousObject(
    final int distance,
    final RoomObjectOrdering ordering,
  ) => examineObject(
    direction: -1,
    distance: distance,
    startCoordinates: playerCoordinates,
    ordering: ordering,
  );

  /// Return the [RoomObject] with the given [id].
  RoomObject? findRoomObject(final String id) {
    for (final object in _room!.objects) {
      if (object.id == id) {
        return object;
      }
    }
    return null;
  }

  /// Return the coordinates for the given [object].
  Point<int> findObjectCoordinates(final RoomObject object) {
    for (final MapEntry(key: coordinates, value: roomObject)
        in _roomObjects.entries) {
      if (roomObject == object) {
        return coordinates;
      }
    }
    throw StateError('Could not find object ${object.name} in $room.');
  }

  /// Move [object] to the [coordinates].
  void moveRoomObject(final RoomObject object, final Point<int> coordinates) {
    final oldCoordinates = findObjectCoordinates(object);
    if (oldCoordinates == coordinates) {
      return; // Nothing to do.
    }
    if (oldCoordinates == playerCoordinates) {
      object.onLeave?.call(this);
    }
    _roomObjects.remove(oldCoordinates);
    _roomObjects[coordinates] = object;
    if (coordinates == playerCoordinates) {
      object.onApproach?.call(this);
    }
  }
}
