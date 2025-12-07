import 'package:angstrom/angstrom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A class for ticking an [engine].
///
/// This widget takes care of calling `engine.init`, so you don't have to.
class EngineTicker extends StatefulWidget {
  /// Create an instance.
  const EngineTicker({required this.engine, required this.child, super.key});

  /// The engine to use.
  final AngstromEngine engine;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Create state for this widget.
  @override
  EngineTickerState createState() => EngineTickerState();
}

/// State for [EngineTicker].
class EngineTickerState extends State<EngineTicker>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// The last elapsed [Duration].
  Duration? _lastElapsed;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _ticker = createTicker((final elapsed) {
      final lastElapsed = _lastElapsed ?? elapsed;
      _lastElapsed = elapsed;
      final delta = elapsed.inMilliseconds - lastElapsed.inMilliseconds;
      widget.engine.onTick(delta);
    });
    widget.engine.init();
    _ticker.start();
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => widget.child;
}
