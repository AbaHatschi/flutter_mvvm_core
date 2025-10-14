import 'dart:async';

import 'package:flutter/foundation.dart';

import 'log_entry.dart';
import 'log_level.dart';

/// Central logging service for the application
/// Provides type-safe, configurable logging with different output options
/// Singleton pattern ensures consistent logging throughout the application
class Logger {
  Logger._();
  static Logger? _instance;
  static Logger get instance => _instance ??= Logger._();

  /// Current minimum log level (messages below this level are ignored)
  LogLevel _minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Whether to print logs to console
  bool _printToConsole = true;

  /// Enable or disable console output
  bool get printToConsole => _printToConsole;

  /// Enable or disable console output
  set printToConsole(bool enabled) {
    _printToConsole = enabled;
    debug('Console output ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Stream controller for log entries (for UI integration)
  final StreamController<LogEntry> _logStreamController =
      StreamController<LogEntry>.broadcast();

  /// Stream of all log entries (for UI components)
  Stream<LogEntry> get logStream => _logStreamController.stream;

  /// List of recent log entries (limited to prevent memory issues)
  final List<LogEntry> _recentLogs = <LogEntry>[];
  static const int _maxRecentLogs = 1000;

  /// Gets the current minimum log level
  LogLevel get minimumLevel => _minimumLevel;

  /// Sets the minimum log level
  void setMinimumLevel(LogLevel level) {
    _minimumLevel = level;
    debug('Logger minimum level set to: ${level.label}');
  }

  /// Gets recent log entries (useful for debug screens)
  List<LogEntry> getRecentLogs({LogLevel? minimumLevel}) {
    if (minimumLevel == null) {
      return List<LogEntry>.from(_recentLogs);
    }
    return _recentLogs
        .where((LogEntry entry) => entry.level.isAtLeastLevel(minimumLevel))
        .toList();
  }

  /// Clears all recent logs
  void clearRecentLogs() {
    _recentLogs.clear();
    debug('Recent logs cleared');
  }

  /// Core logging method - all other methods delegate to this
  void _log({
    required LogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    String? source,
    Map<String, Object?>? data,
  }) {
    // Check if we should log this level
    if (!level.isAtLeastLevel(_minimumLevel)) {
      return;
    }

    // Create log entry
    final LogEntry entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      source: source,
      data: data,
    );

    // Store in recent logs (with size limit)
    _recentLogs.add(entry);
    if (_recentLogs.length > _maxRecentLogs) {
      _recentLogs.removeAt(0);
    }

    // Output to console if enabled
    if (_printToConsole) {
      debugPrint(entry.formatForConsole());
    }

    // Broadcast to stream listeners
    _logStreamController.add(entry);
  }

  // Convenience methods for different log levels

  /// Logs debug information (only in debug mode by default)
  void debug(String message, {String? source, Map<String, Object?>? data}) {
    _log(level: LogLevel.debug, message: message, source: source, data: data);
  }

  /// Logs general information
  void info(String message, {String? source, Map<String, Object?>? data}) {
    _log(level: LogLevel.info, message: message, source: source, data: data);
  }

  /// Logs successful operations
  void success(String message, {String? source, Map<String, Object?>? data}) {
    _log(level: LogLevel.success, message: message, source: source, data: data);
  }

  /// Logs warning conditions
  void warning(
    String message, {
    Object? error,
    String? source,
    Map<String, Object?>? data,
  }) {
    _log(
      level: LogLevel.warning,
      message: message,
      error: error,
      source: source,
      data: data,
    );
  }

  /// Logs error conditions
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? source,
    Map<String, Object?>? data,
  }) {
    _log(
      level: LogLevel.error,
      message: message,
      error: error,
      stackTrace: stackTrace,
      source: source,
      data: data,
    );
  }

  /// Logs critical errors
  void critical(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? source,
    Map<String, Object?>? data,
  }) {
    _log(
      level: LogLevel.critical,
      message: message,
      error: error,
      stackTrace: stackTrace,
      source: source,
      data: data,
    );
  }

  /// Logs the result of a Future operation
  Future<T> logFuture<T>(
    String operationName,
    Future<T> future, {
    String? source,
    Map<String, Object?>? data,
  }) async {
    info('Starting: $operationName', source: source, data: data);

    try {
      final T result = await future;
      success('Completed: $operationName', source: source, data: data);
      return result;
    } catch (error, stackTrace) {
      this.error(
        'Failed: $operationName',
        error: error,
        stackTrace: stackTrace,
        source: source,
        data: data,
      );
      rethrow;
    }
  }

  /// Closes the logger and cleans up resources
  Future<void> close() async {
    await _logStreamController.close();
    _recentLogs.clear();
  }
}
