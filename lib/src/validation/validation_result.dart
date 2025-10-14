import 'package:meta/meta.dart';

/// Represents the result of a validation operation
/// Contains information about validation success/failure and error messages
@immutable
class ValidationResult {
  const ValidationResult({
    this.isValid = true,
    this.errors = const <String>[],
    this.fieldName,
  });

  /// Creates a successful validation result
  const ValidationResult.success() : this();

  /// Creates a failed validation result with error messages
  const ValidationResult.failure(List<String> errors, {String? fieldName})
    : this(isValid: false, errors: errors, fieldName: fieldName);

  /// Creates a failed validation result with a single error message
  ValidationResult.singleError(String error, {String? fieldName})
    : this(isValid: false, errors: <String>[error], fieldName: fieldName);

  /// Whether the validation passed
  final bool isValid;

  /// List of validation error messages
  final List<String> errors;

  /// Optional field name for context
  final String? fieldName;

  /// Whether the validation failed
  bool get isInvalid => !isValid;

  /// Whether there are any errors
  bool get hasErrors => errors.isNotEmpty;

  /// Gets the first error message (null if no errors)
  String? get firstError => errors.isNotEmpty ? errors.first : null;

  /// Gets all error messages as a single string, separated by newlines
  String get errorMessage => errors.join('\n');

  /// Combines this result with another validation result
  /// The combined result is valid only if both are valid
  ValidationResult combine(ValidationResult other) {
    if (isValid && other.isValid) {
      return const ValidationResult.success();
    }

    final List<String> combinedErrors = <String>[...errors, ...other.errors];

    return ValidationResult.failure(
      combinedErrors,
      fieldName: fieldName ?? other.fieldName,
    );
  }

  /// Combines this result with multiple other validation results
  ValidationResult combineAll(List<ValidationResult> others) {
    ValidationResult result = this;
    for (final ValidationResult other in others) {
      result = result.combine(other);
    }
    return result;
  }

  /// Creates a copy with updated values
  ValidationResult copyWith({
    bool? isValid,
    List<String>? errors,
    String? fieldName,
  }) {
    return ValidationResult(
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
      fieldName: fieldName ?? this.fieldName,
    );
  }

  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult.success()';
    }
    return 'ValidationResult.failure(${errors.length} errors${fieldName != null ? ' for $fieldName' : ''})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! ValidationResult) {
      return false;
    }
    return isValid == other.isValid &&
        errors.length == other.errors.length &&
        errors.every((String error) => other.errors.contains(error)) &&
        fieldName == other.fieldName;
  }

  @override
  int get hashCode => Object.hash(isValid, errors, fieldName);
}
