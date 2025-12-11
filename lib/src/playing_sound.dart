import 'package:angstrom/angstrom.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// A sound which is playing.
class PlayingSound {
  /// Create an instance.
  const PlayingSound({required this.reference, required this.handle});

  /// The sound reference.
  final SoundReference reference;

  /// The sound handle.
  final SoundHandle handle;
}
