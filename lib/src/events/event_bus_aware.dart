import 'base_event.dart';
import 'event_bus.dart';
import 'event_subscription.dart';

/// Interface for ViewModels that want to use EventBus functionality
/// Provides a clean contract for event publishing and subscribing
///
/// Usage:
/// ```dart
/// class UserViewModel extends BaseViewModel implements EventBusAware {
///   @override
///   void publishEvent<T extends BaseEvent>(T event) {
///     EventBus.instance.publish(event);
///   }
///
///   @override
///   EventSubscription<T> subscribeToEvent<T extends BaseEvent>(
///     void Function(T) handler
///   ) {
///     return EventBus.instance.subscribe<T>(handler);
///   }
/// }
/// ```
abstract interface class EventBusAware {
  /// Publishes an event to the EventBus
  void publishEvent<T extends BaseEvent>(T event);

  /// Subscribes to events of a specific type
  EventSubscription<T> subscribeToEvent<T extends BaseEvent>(
    void Function(T event) handler,
  );

  /// Subscribes to events of a specific type, automatically unsubscribing after first event
  EventSubscription<T> subscribeOnceToEvent<T extends BaseEvent>(
    void Function(T event) handler,
  ) {
    return EventBus.instance.subscribeOnce<T>(handler);
  }
}
