/// Various type definitions used throughout the engine.
library;

import 'package:angstrom/angstrom.dart';

/// The type of a function which is called with an angstrom engine as its only
/// parameter.
typedef AngstromCallback = void Function(AngstromEngine engine);
