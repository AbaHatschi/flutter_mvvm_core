import 'dart:async';

import 'package:flutter/foundation.dart';

import 'base_event.dart';
import 'event_subscription.dart';

/// Central EventBus for loose-coupled communication between components
/// Similar to Prism's EventAggregator in C#
/// Singleton pattern ensures global access throughout the application
class EventBus {
  EventBus._();
  static EventBus? _instance;
  static EventBus get instance => _instance ??= EventBus._();

  /// Stream controllers for each event type
  final Map<Type, StreamController<BaseEvent>> _controllers =
      <Type, StreamController<BaseEvent>>{};

  /// Active subscriptions for cleanup tracking
  final List<EventSubscription<BaseEvent>> _subscriptions =
      <EventSubscription<BaseEvent>>[];

  /// Publishes an event to all subscribers of that event type
  ///
  /// Example:
  /// ```dart
  /// EventBus.instance.publish(UserLoggedInEvent(user));
  /// ```
  void publish<T extends BaseEvent>(T event) {
    final Type eventType = T;

    debugPrint('📤 Publishing event: ${event.eventType}');

    // Get or create controller for this event type
    final StreamController<BaseEvent> controller = _controllers.putIfAbsent(
      eventType,
      () => StreamController<BaseEvent>.broadcast(),
    );

    // Publish the event
    controller.add(event);

    debugPrint(
      '✅ Event published: ${event.eventType} (${_getSubscriberCount(eventType)} subscribers)',
    );
  }

  /// Subscribes to events of a specific type
  /// Returns an EventSubscription that can be used to cancel the subscription
  ///
  /// Example:
  /// ```dart
  /// final subscription = EventBus.instance.subscribe<UserLoggedInEvent>((event) {
  ///   print('User ${event.user.name} logged in');
  /// });
  /// ```
  EventSubscription<T> subscribe<T extends BaseEvent>(
    void Function(T event) onEvent,
  ) {
    final Type eventType = T;

    debugPrint('📥 Subscribing to event: $eventType');

    // Get or create controller for this event type
    final StreamController<BaseEvent> controller = _controllers.putIfAbsent(
      eventType,
      () => StreamController<BaseEvent>.broadcast(),
    );

    // Create typed subscription
    // ignore: cancel_subscriptions - Managed by EventSubscription wrapper
    final StreamSubscription<T> streamSubscription = controller.stream
        .where((BaseEvent event) => event is T)
        .cast<T>()
        .listen(onEvent);

    // Wrap in EventSubscription for management
    final EventSubscription<T> subscription = EventSubscription<T>.create(
      streamSubscription,
    );
    _subscriptions.add(subscription);

    debugPrint(
      '✅ Subscription created for: $eventType (Total: ${_getSubscriberCount(eventType)})',
    );

    return subscription;
  }

  /// Subscribes to events of a specific type only once
  /// Automatically unsubscribes after the first event
  ///
  /// Example:
  /// ```dart
  /// EventBus.instance.subscribeOnce<AppInitializedEvent>((event) {
  ///   print('App is ready!');
  /// });
  /// ```
  EventSubscription<T> subscribeOnce<T extends BaseEvent>(
    void Function(T event) onEvent,
  ) {
    late EventSubscription<T> subscription;

    subscription = subscribe<T>((T event) {
      onEvent(event);
      subscription.cancel(); // Auto-unsubscribe
    });

    return subscription;
  }

  /// Gets the number of active subscribers for an event type
  int _getSubscriberCount(Type eventType) {
    final StreamController<BaseEvent>? controller = _controllers[eventType];
    if (controller == null) {
      return 0;
    }

    return controller.hasListener
        ? 1
        : 0; // Broadcast streams don't expose listener count
  }

  /// Removes all subscriptions and clears all controllers
  /// Useful for testing or app shutdown
  Future<void> clear() async {
    debugPrint('🧹 Clearing EventBus...');

    // Cancel all subscriptions
    for (final EventSubscription<BaseEvent> subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // Close all controllers
    for (final StreamController<BaseEvent> controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();

    debugPrint('✅ EventBus cleared');
  }

  /// Gets debug information about the current state
  Map<String, Object> getDebugInfo() {
    return <String, Object>{
      'activeControllers': _controllers.length,
      'activeSubscriptions': _subscriptions.length,
      'eventTypes': _controllers.keys
          .map((Type type) => type.toString())
          .toList(),
    };
  }
}
