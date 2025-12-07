import 'package:flutter_soloud/flutter_soloud.dart';

/// A class which holds both a [source] and a [handle].
class AudioSourceAndHandle {
  /// Create an instance.
  const AudioSourceAndHandle({required this.source, required this.handle});

  /// The sound source to use.
  final AudioSource source;

  /// The sound handle to use.
  final SoundHandle handle;
}
