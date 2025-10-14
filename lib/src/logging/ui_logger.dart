import 'package:flutter/material.dart';

import 'log_entry.dart';
import 'log_level.dart';
import 'logger.dart';

/// UI integration for the Logger - provides toast/snackbar functionality
/// Can be used to show log messages directly in the UI
class UiLogger {
  UiLogger._();
  static UiLogger? _instance;
  static UiLogger get instance => _instance ??= UiLogger._();

  /// Whether to automatically show UI messages for certain log levels
  bool _showAutoMessages = false;

  /// Minimum log level for auto-showing UI messages
  LogLevel _autoMessageLevel = LogLevel.warning;

  /// Current BuildContext for showing messages (set by app)
  BuildContext? uiContext;

  /// Enables/disables automatic UI messages for log entries
  void setAutoMessages(
    bool enabled, {
    LogLevel minimumLevel = LogLevel.warning,
  }) {
    _showAutoMessages = enabled;
    _autoMessageLevel = minimumLevel;

    if (enabled) {
      // Subscribe to log stream
      Logger.instance.logStream.listen(_handleLogEntry);
    }
  }

  /// Handles incoming log entries for auto UI messages
  void _handleLogEntry(LogEntry entry) {
    if (_showAutoMessages &&
        entry.level.isAtLeastLevel(_autoMessageLevel) &&
        uiContext != null) {
      showLogMessage(entry);
    }
  }

  /// Shows a log entry as a SnackBar
  void showLogMessage(LogEntry entry) {
    if (uiContext == null) {
      return;
    }

    final SnackBar snackBar = SnackBar(
      content: Text('${entry.level.emoji} ${entry.message}'),
      backgroundColor: _getColorForLevel(entry.level),
      duration: _getDurationForLevel(entry.level),
      action: entry.level == LogLevel.error || entry.level == LogLevel.critical
          ? SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () => _showErrorDetails(entry),
            )
          : null,
    );

    ScaffoldMessenger.of(uiContext!).showSnackBar(snackBar);
  }

  /// Shows success message with green color
  void showSuccess(String message) {
    Logger.instance.success(message);

    if (uiContext != null) {
      final SnackBar snackBar = SnackBar(
        content: Text('✅ $message'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(uiContext!).showSnackBar(snackBar);
    }
  }

  /// Shows error message with red color and details button
  void showError(String message, {Object? error}) {
    Logger.instance.error(message, error: error);

    if (uiContext != null) {
      final SnackBar snackBar = SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
        action: error != null
            ? SnackBarAction(
                label: 'Details',
                textColor: Colors.white,
                onPressed: () => _showErrorDialog(message, error),
              )
            : null,
      );
      ScaffoldMessenger.of(uiContext!).showSnackBar(snackBar);
    }
  }

  /// Shows warning message with orange color
  void showWarning(String message) {
    Logger.instance.warning(message);

    if (uiContext != null) {
      final SnackBar snackBar = SnackBar(
        content: Text('⚠️ $message'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(uiContext!).showSnackBar(snackBar);
    }
  }

  /// Shows info message with blue color
  void showInfo(String message) {
    Logger.instance.info(message);

    if (uiContext != null) {
      final SnackBar snackBar = SnackBar(
        content: Text('ℹ️ $message'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(uiContext!).showSnackBar(snackBar);
    }
  }

  /// Gets appropriate color for log level
  Color _getColorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.success:
        return Colors.green;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.critical:
        return Colors.red.shade900;
    }
  }

  /// Gets appropriate duration for log level
  Duration _getDurationForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
      case LogLevel.info:
        return const Duration(seconds: 2);
      case LogLevel.success:
        return const Duration(seconds: 2);
      case LogLevel.warning:
        return const Duration(seconds: 3);
      case LogLevel.error:
      case LogLevel.critical:
        return const Duration(seconds: 4);
    }
  }

  /// Shows detailed error information in a dialog
  void _showErrorDetails(LogEntry entry) {
    _showErrorDialog(entry.message, entry.error);
  }

  /// Shows error dialog with detailed information
  void _showErrorDialog(String message, Object? error) {
    if (uiContext == null) {
      return;
    }

    showDialog<void>(
      context: uiContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Message:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(message),
              if (error != null) ...<Widget>[
                const SizedBox(height: 16),
                Text('Error:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(error.toString()),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
