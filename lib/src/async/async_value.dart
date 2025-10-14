import 'package:meta/meta.dart';

/// Represents the state of an asynchronous operation
@immutable
sealed class AsyncValue<T> {
  const AsyncValue();

  /// Creates an initial/idle state
  const factory AsyncValue.idle() = AsyncIdle<T>;

  /// Creates a loading state
  const factory AsyncValue.loading() = AsyncLoading<T>;

  /// Creates a data state with the given value
  const factory AsyncValue.data(T value) = AsyncData<T>;

  /// Creates an error state with the given error and optional stack trace
  const factory AsyncValue.error(Object error, [StackTrace? stackTrace]) =
      AsyncError<T>;

  /// Returns true if this is a loading state
  bool get isLoading => this is AsyncLoading<T>;

  /// Returns true if this is a data state
  bool get hasValue => this is AsyncData<T>;

  /// Returns true if this is an error state
  bool get hasError => this is AsyncError<T>;

  /// Returns true if this is an idle state
  bool get isIdle => this is AsyncIdle<T>;

  /// Returns the data if available, null otherwise
  T? get valueOrNull => switch (this) {
    AsyncData<T>(value: final T value) => value,
    _ => null,
  };

  /// Returns the error if available, null otherwise
  Object? get errorOrNull => switch (this) {
    AsyncError<T>(error: final Object error) => error,
    _ => null,
  };

  /// Maps the data value if available
  AsyncValue<R> map<R>(R Function(T) mapper) => switch (this) {
    AsyncIdle<T>() => AsyncValue<R>.idle(),
    AsyncLoading<T>() => AsyncValue<R>.loading(),
    AsyncData<T>(value: final T value) => AsyncValue<R>.data(mapper(value)),
    AsyncError<T>(
      error: final Object error,
      stackTrace: final StackTrace? stackTrace,
    ) =>
      AsyncValue<R>.error(error, stackTrace),
  };

  /// Pattern matching on the async value
  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error, StackTrace? stackTrace) error,
  }) => switch (this) {
    AsyncIdle<T>() => idle(),
    AsyncLoading<T>() => loading(),
    AsyncData<T>(value: final T value) => data(value),
    AsyncError<T>(
      error: final Object err,
      stackTrace: final StackTrace? stackTrace,
    ) =>
      error(err, stackTrace),
  };

  /// Pattern matching with optional parameters
  R maybeWhen<R>({
    R Function()? idle,
    R Function()? loading,
    R Function(T data)? data,
    R Function(Object error, StackTrace? stackTrace)? error,
    required R Function() orElse,
  }) => switch (this) {
    AsyncIdle<T>() => idle?.call() ?? orElse(),
    AsyncLoading<T>() => loading?.call() ?? orElse(),
    AsyncData<T>(value: final T value) => data?.call(value) ?? orElse(),
    AsyncError<T>(
      error: final Object err,
      stackTrace: final StackTrace? stackTrace,
    ) =>
      error?.call(err, stackTrace) ?? orElse(),
  };
}

/// Idle/Initial state
final class AsyncIdle<T> extends AsyncValue<T> {
  const AsyncIdle();

  @override
  bool operator ==(Object other) => other is AsyncIdle<T>;

  @override
  int get hashCode => (AsyncIdle).hashCode;

  @override
  String toString() => 'AsyncValue<$T>.idle()';
}

/// Loading state
final class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();

  @override
  bool operator ==(Object other) => other is AsyncLoading<T>;

  @override
  int get hashCode => (AsyncLoading).hashCode;

  @override
  String toString() => 'AsyncValue<$T>.loading()';
}

/// Data state
final class AsyncData<T> extends AsyncValue<T> {
  const AsyncData(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      other is AsyncData<T> && other.value == value;

  @override
  int get hashCode => Object.hash(AsyncData, value);

  @override
  String toString() => 'AsyncValue<$T>.data($value)';
}

/// Error state
final class AsyncError<T> extends AsyncValue<T> {
  const AsyncError(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      other is AsyncError<T> &&
      other.error == error &&
      other.stackTrace == stackTrace;

  @override
  int get hashCode => Object.hash(AsyncError, error, stackTrace);

  @override
  String toString() => 'AsyncValue<$T>.error($error, $stackTrace)';
}
