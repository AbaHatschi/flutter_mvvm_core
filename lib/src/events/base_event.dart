/// Abstract base class for all events in the EventBus system
/// Every event must extend this class to be published/subscribed
abstract class BaseEvent {
  const BaseEvent();

  /// Timestamp when the event was created
  DateTime get timestamp => DateTime.now();

  /// Optional event identifier for debugging
  String get eventType => runtimeType.toString();

  @override
  String toString() => '$eventType at $timestamp';
}
