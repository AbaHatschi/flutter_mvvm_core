import 'package:flutter/foundation.dart';

/// Abstract ViewModel with lifecycle hooks
abstract class BaseViewModel extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isViewLoaded = false;

  bool get isInitialized => _isInitialized;
  bool get isViewLoaded => _isViewLoaded;

  /// Called when the ViewModel instance is loaded
  @mustCallSuper
  Future<void> init() async {
    if (!_isInitialized) {
      _isInitialized = true;
      await onInit();
    }
  }

  /// Called when the View is fully loaded and ready
  @mustCallSuper
  Future<void> viewDidLoad() async {
    if (!_isViewLoaded) {
      _isViewLoaded = true;
      await onViewDidLoad();
    }
  }

  /// Override in Subclasses for ViewModel Initialization
  /// Called once when ViewModel is created
  Future<void> onInit() async {}

  /// Override in Subclasses for View-specific actions
  /// Called once when View is fully loaded
  Future<void> onViewDidLoad() async {}
}
