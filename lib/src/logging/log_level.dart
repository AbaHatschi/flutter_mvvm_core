/// Defines the severity levels for logging
enum LogLevel {
  /// Detailed information for debugging
  debug(0, '🐛', 'DEBUG'),

  /// General information about application flow
  info(1, 'ℹ️', 'INFO'),

  /// Successful operations
  success(2, '✅', 'SUCCESS'),

  /// Warning conditions that don't halt execution
  warning(3, '⚠️', 'WARNING'),

  /// Error conditions that may cause issues
  error(4, '❌', 'ERROR'),

  /// Critical errors that may cause application failure
  critical(5, '🔥', 'CRITICAL');

  const LogLevel(this.priority, this.emoji, this.label);

  /// Numeric priority (higher = more severe)
  final int priority;

  /// Emoji representation for console output
  final String emoji;

  /// Text label for the log level
  final String label;

  /// Returns true if this level is equal or higher priority than [other]
  bool isAtLeastLevel(LogLevel other) => priority >= other.priority;

  @override
  String toString() => label;
}
