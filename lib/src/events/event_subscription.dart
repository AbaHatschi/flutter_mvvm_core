import 'dart:async';

import 'base_event.dart';

/// Manages event subscriptions for the EventBus
/// Handles type-safe subscription and unsubscription
class EventSubscription<T extends BaseEvent> {
  /// Creates a new EventSubscription
  factory EventSubscription.create(StreamSubscription<T> subscription) {
    return EventSubscription<T>._(subscription, T);
  }
  EventSubscription._(this._subscription, this._eventType);

  final StreamSubscription<T> _subscription;
  final Type _eventType;

  /// The event type this subscription is listening for
  Type get eventType => _eventType;

  /// Whether this subscription is active
  bool get isActive => !_subscription.isPaused;

  /// Cancels this subscription
  Future<void> cancel() async {
    await _subscription.cancel();
  }

  /// Pauses this subscription temporarily
  void pause() {
    _subscription.pause();
  }

  /// Resumes a paused subscription
  void resume() {
    _subscription.resume();
  }
}
