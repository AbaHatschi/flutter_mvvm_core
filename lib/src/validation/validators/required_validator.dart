import '../base_validator.dart';
import '../validation_result.dart';

/// Validator that checks if a value is not null or empty
class RequiredValidator<T> extends BaseValidator<T> {
  const RequiredValidator({this.message = 'This field is required'});

  final String message;

  @override
  ValidationResult validate(T? value, {String? fieldName}) {
    final bool isEmpty = _isEmpty(value);

    if (isEmpty) {
      final String errorMessage = fieldName != null
          ? '$fieldName is required'
          : message;
      return ValidationResult.singleError(errorMessage, fieldName: fieldName);
    }

    return const ValidationResult.success();
  }

  /// Checks if a value is considered empty
  bool _isEmpty(T? value) {
    if (value == null) {
      return true;
    }

    if (value is String) {
      return value.trim().isEmpty;
    }
    if (value is Iterable) {
      return value.isEmpty;
    }
    if (value is Map) {
      return value.isEmpty;
    }

    return false;
  }
}
