import 'log_level.dart';

/// Represents a single log entry with all relevant information
class LogEntry {
  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
    this.source,
    this.data,
  });

  /// The severity level of this log entry
  final LogLevel level;

  /// The main log message
  final String message;

  /// When this log entry was created
  final DateTime timestamp;

  /// Optional error object associated with this log
  final Object? error;

  /// Optional stack trace for errors
  final StackTrace? stackTrace;

  /// Optional source identifier (e.g., class name, method name)
  final String? source;

  /// Optional additional data as key-value pairs
  final Map<String, Object?>? data;

  /// Creates a formatted string representation for console output
  String formatForConsole() {
    final StringBuffer buffer = StringBuffer();

    // Timestamp and level
    final String timeStr = timestamp.toIso8601String().substring(
      11,
      23,
    ); // HH:mm:ss.SSS
    buffer.write('[$timeStr] ${level.emoji} ${level.label}');

    // Source if available
    if (source != null) {
      buffer.write(' [$source]');
    }

    // Main message
    buffer.write(': $message');

    // Error details if available
    if (error != null) {
      buffer.write('\n  Error: $error');
    }

    // Additional data if available
    if (data != null && data!.isNotEmpty) {
      buffer.write('\n  Data: $data');
    }

    // Stack trace for errors (only first few lines)
    if (stackTrace != null) {
      final List<String> lines = stackTrace.toString().split('\n');
      buffer.write('\n  Stack: ${lines.take(3).join('\n         ')}');
      if (lines.length > 3) {
        buffer.write('\n         ... (${lines.length - 3} more lines)');
      }
    }

    return buffer.toString();
  }

  /// Creates a copy with updated fields
  LogEntry copyWith({
    LogLevel? level,
    String? message,
    DateTime? timestamp,
    Object? error,
    StackTrace? stackTrace,
    String? source,
    Map<String, Object?>? data,
  }) {
    return LogEntry(
      level: level ?? this.level,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      source: source ?? this.source,
      data: data ?? this.data,
    );
  }

  @override
  String toString() => formatForConsole();
}
