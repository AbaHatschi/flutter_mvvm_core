import 'validation_result.dart';

/// Abstract base class for all validators
/// Provides a consistent interface for validation operations
abstract class BaseValidator<T> {
  const BaseValidator();

  /// Validates the given value and returns a ValidationResult
  /// Override this method in concrete validator implementations
  ValidationResult validate(T? value, {String? fieldName});

  /// Validates the value and throws an exception if invalid
  /// Useful for scenarios where you want to halt execution on validation failure
  void validateOrThrow(T? value, {String? fieldName}) {
    final ValidationResult result = validate(value, fieldName: fieldName);
    if (result.isInvalid) {
      throw ValidationException(result);
    }
  }

  /// Checks if the value is valid (convenience method)
  bool isValid(T? value, {String? fieldName}) {
    return validate(value, fieldName: fieldName).isValid;
  }

  /// Gets the first error message for the value (null if valid)
  String? getFirstError(T? value, {String? fieldName}) {
    return validate(value, fieldName: fieldName).firstError;
  }

  /// Combines this validator with another validator using AND logic
  /// Both validators must pass for the combined validation to be successful
  CombinedValidator<T> and(BaseValidator<T> other) {
    return CombinedValidator<T>(<BaseValidator<T>>[this, other]);
  }
}

/// Validator that combines multiple validators using AND logic
class CombinedValidator<T> extends BaseValidator<T> {
  const CombinedValidator(this.validators);

  final List<BaseValidator<T>> validators;

  @override
  ValidationResult validate(T? value, {String? fieldName}) {
    ValidationResult result = const ValidationResult.success();

    for (final BaseValidator<T> validator in validators) {
      final ValidationResult validatorResult = validator.validate(
        value,
        fieldName: fieldName,
      );
      result = result.combine(validatorResult);
    }

    return result;
  }

  /// Adds another validator to the combination
  @override
  CombinedValidator<T> and(BaseValidator<T> validator) {
    return CombinedValidator<T>(<BaseValidator<T>>[...validators, validator]);
  }
}

/// Exception thrown when validation fails
class ValidationException implements Exception {
  const ValidationException(this.result);

  final ValidationResult result;

  @override
  String toString() {
    return 'ValidationException: ${result.errorMessage}';
  }
}
