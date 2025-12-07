import 'package:angstrom/angstrom.dart' show AngstromEngine;
import 'package:angstrom/src/angstrom_engine.dart' show AngstromEngine;
import 'package:angstrom/typedefs.dart';

/// A task for an [AngstromEngine] to perform when the game loop has reached
/// [milliseconds].
class AngstromTask {
  /// Create an instance.
  const AngstromTask({required this.milliseconds, required this.callback});

  /// The minimum number of milliseconds which must have elapsed before this
  /// task will run.
  final int milliseconds;

  /// The function to perform.
  final AngstromCallback callback;
}
