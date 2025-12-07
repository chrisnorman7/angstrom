# Angstrom

## Description

This package provides the ability to create top-down audio games with very little code.

## Example

```dart
// ...
class MyEngine extends AngstromEngine {
  /// Create an instance.
  MyEngine({required super.playerCharacter});
}
```

The engine has the public-facing API which you can use control your game. It has an `events` stream which can be listened to.

## Interface

You can rig up an interface fairly quickly with Angstrom, but it also has sensible defaults:

```dart
// .
Widget build(final BuildContext context) {
  return GameScreen(
    engine: engine,
    title: 'Exciting Game'
  );
}
```

## Editing maps

If you don't fancy hand-coding your own maps, include an `AngstromEditor` in your game's menu:

```dart
if (kDebugMode && !kIsWeb ) {
  context.pushWidgetBuilder((_) {
    const sounds = Assets.sounds;
    final footstepSounds = sounds.footsteps;
    return Cancel(
      child: AngstromEditor(
        directory: Directory('rooms'),
        footsteps: [
          FootstepsSounds(
            name: 'carpet_hard_surface',
            soundPaths: footstepSounds.carpetHardSurface.values,
          ),
          FootstepsSounds(
            name: 'Concrete',
            soundPaths: footstepSounds.concrete.values,
          ),
          FootstepsSounds(
            name: 'Gravel',
            soundPaths: footstepSounds.gravel.values,
          ),
        ],
        musicSoundPaths: sounds.music.values,
        ambianceSoundPaths: sounds.ambiances.values,
      ),
    );
  });
}
```

The editor package can be found on [pub.dev](https://pub.dev/packages/angstrom_editor).
