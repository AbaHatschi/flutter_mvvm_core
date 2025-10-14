# Flutter MVVM Core

A powerful Flutter package that provides a complete MVVM architecture with asynchronous state management, event system, logging and validation.

## Features

- **🔄 AsyncValue**: Elegant handling of asynchronous states (loading, success, error)
- **📊 MVVM Architecture**: Clean separation of View, ViewModel and Model
- **🚌 Event bus**: Loosely coupled communication between components
- **📝 Logging System**: Structured logging with different log levels
- **✅ Validation Framework**: Comprehensive validation system for forms
- **🎨 Custom Widgets**: Prefabricated UI components for fast development

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_mvvm_core:
    git:
      url: https://github.com/AbaHatschi/flutter_mvvm_core.git
```

## Quick start

### 1. Create ViewModel

```dart
import 'package:flutter_mvvm_core/flutter_mvvm_core.dart';

class UserViewModel extends AsyncViewModel<User> {
  final UserService _userService;

  UserViewModel(this._userService);

  Future<void> loadUser(String userId) async {
    await executeAsync(() => _userService.getUser(userId));
  }
}
```

### 2. View with AsyncWidget

```dart
class UserView extends StatelessWidget {
  final UserViewModel viewModel;

  const UserView({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncWidget<User>(
        asyncValue: viewModel.asyncValue,
        data: (user) => UserProfile(user: user),
        loading: () => const CircularProgressIndicator(),
        error: (error) => Text('Error: $error'),
      ),
    );
  }
}
```

### 3. Use validation

```dart
final validator = ValidationChain([
  RequiredValidator(),
  EmailValidator(),
  LengthValidator(minLength: 5),
]);

final result = validator.validate('test@example.com');
if (result.isValid) {
  // Input is valid
}
```

### 4. Use Event Bus

```dart
// Define event
class UserUpdatedEvent extends BaseEvent {
  final User user;
  UserUpdatedEvent(this.user);
}

// Emit event
EventBus.instance.emit(UserUpdatedEvent(user));

// Receive event
EventBus.instance.on<UserUpdatedEvent>().listen((event) {
  print('User updated: ${event.user.name}');
});
```

## Architecture

The package follows the MVVM architecture:

- **View**: UI-Components (Widgets)
- **ViewModel**: Business logic and status management
- **Model**: Data structures and services

## Documentation

Further examples and detailed documentation can be found in the `/example` folders of the respective components.

## Contributions

Contributions are welcome! Please:

1. fork the repository
2. create a feature branch
3. commit your changes
4. push to your branch
5. create a pull request

## License

This project is licensed under a Non-Commercial License. See [LICENSE](LICENSE) for details.

**Summary:**
- ✅ Free for personal, educational, and open-source projects
- ✅ Modifications and contributions welcome
- ❌ Commercial use requires explicit permission
- 📧 Contact AbaHatschi for commercial licensing inquiries

## Report a problem

In the event of problems or feature requests, please create a [Issue](https://github.com/AbaHatschi/flutter_mvvm_core/issues).
