import 'package:flutter/material.dart';

import 'async_value.dart';

/// Widget that builds UI based on AsyncValue state
class AsyncWidget<T> extends StatelessWidget {
  const AsyncWidget({
    super.key,
    required this.value,
    required this.data,
    this.idle,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? idle;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      idle: () => idle?.call() ?? const SizedBox.shrink(),
      loading: () => loading?.call() ?? const _DefaultLoadingWidget(),
      data: data,
      error: (Object error, StackTrace? stackTrace) =>
          this.error?.call(error, stackTrace) ??
          _DefaultErrorWidget(error: error, stackTrace: stackTrace),
    );
  }
}

/// Default loading widget
class _DefaultLoadingWidget extends StatelessWidget {
  const _DefaultLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Default error widget
class _DefaultErrorWidget extends StatelessWidget {
  const _DefaultErrorWidget({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          if (stackTrace != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Tap for details',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Convenient builder function for simple async widgets
Widget asyncBuilder<T>({
  required AsyncValue<T> value,
  required Widget Function(T data) data,
  Widget Function()? idle,
  Widget Function()? loading,
  Widget Function(Object error, StackTrace? stackTrace)? error,
}) {
  return AsyncWidget<T>(
    value: value,
    data: data,
    idle: idle,
    loading: loading,
    error: error,
  );
}
