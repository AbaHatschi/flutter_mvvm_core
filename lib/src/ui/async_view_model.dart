import 'package:flutter/foundation.dart';

import '../async/async_value.dart';
import 'base_view_model.dart';

/// Extended ViewModel with async state management capabilities
/// Use this for ViewModels that need to handle async operations with loading/error states
abstract class AsyncViewModel extends BaseViewModel {
  /// Helper method to execute async operations with state management
  Future<void> executeAsync<T>(
    Future<T> Function() operation,
    ValueChanged<AsyncValue<T>> onStateChanged,
  ) async {
    onStateChanged(AsyncValue<T>.loading());
    try {
      final T result = await operation();
      onStateChanged(AsyncValue<T>.data(result));
    } catch (error, stackTrace) {
      onStateChanged(AsyncValue<T>.error(error, stackTrace));
    }
  }

  /// Helper method for operations that don't return data
  Future<void> executeAsyncVoid(
    Future<void> Function() operation,
    ValueChanged<AsyncValue<void>> onStateChanged,
  ) async {
    await executeAsync<void>(operation, onStateChanged);
  }

  /// Helper method to update a specific async state property
  void updateAsyncState<T>(
    AsyncValue<T> Function() getter,
    void Function(AsyncValue<T>) setter,
    Future<T> Function() operation,
  ) {
    executeAsync<T>(operation, (AsyncValue<T> newState) {
      setter(newState);
      notifyListeners();
    });
  }
}
