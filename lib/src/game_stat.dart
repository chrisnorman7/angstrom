/// The type of a stats map.
typedef StatsMap = Map<String, dynamic>;

/// A stat for any object in a game.
class GameStat<T> {
  /// Create an instance.
  const GameStat({required this.id, required this.defaultValue});

  /// The ID of this stat.
  final String id;

  /// The default value for this stat.
  final T defaultValue;

  /// Get the value of this stat from [map].
  T getValue(final StatsMap map) => (map[id] as T?) ?? defaultValue;

  /// Set the [value] of this stat in the given [map].
  void setValue(final StatsMap map, final T value) => map[id] = value;

  /// Reset the value of this stat to [defaultValue] in [map].
  void resetValue(final StatsMap map) => setValue(map, defaultValue);
}
