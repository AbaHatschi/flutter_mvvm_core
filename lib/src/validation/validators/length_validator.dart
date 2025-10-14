import '../base_validator.dart';
import '../validation_result.dart';

/// Validator that checks if a value meets minimum length requirements
class MinLengthValidator extends BaseValidator<String> {
  const MinLengthValidator(
    this.minLength, {
    this.message,
    this.includeActualLength = false,
  });

  final int minLength;
  final String? message;
  final bool includeActualLength;

  @override
  ValidationResult validate(String? value, {String? fieldName}) {
    // Allow null/empty values - use RequiredValidator if needed
    if (value == null || value.isEmpty) {
      return const ValidationResult.success();
    }

    if (value.length < minLength) {
      String errorMessage;

      if (message != null) {
        errorMessage = message!;
      } else {
        final String field = fieldName ?? 'Value';
        if (includeActualLength) {
          errorMessage =
              '$field must be at least $minLength characters long (current: ${value.length})';
        } else {
          errorMessage = '$field must be at least $minLength characters long';
        }
      }

      return ValidationResult.singleError(errorMessage, fieldName: fieldName);
    }

    return const ValidationResult.success();
  }

  /// Static method to check if a string meets minimum length
  static bool meetsMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }
}

/// Validator that checks if a value meets maximum length requirements
class MaxLengthValidator extends BaseValidator<String> {
  const MaxLengthValidator(
    this.maxLength, {
    this.message,
    this.includeActualLength = false,
  });

  final int maxLength;
  final String? message;
  final bool includeActualLength;

  @override
  ValidationResult validate(String? value, {String? fieldName}) {
    // Allow null/empty values
    if (value == null || value.isEmpty) {
      return const ValidationResult.success();
    }

    if (value.length > maxLength) {
      String errorMessage;

      if (message != null) {
        errorMessage = message!;
      } else {
        final String field = fieldName ?? 'Value';
        if (includeActualLength) {
          errorMessage =
              '$field must not exceed $maxLength characters (current: ${value.length})';
        } else {
          errorMessage = '$field must not exceed $maxLength characters';
        }
      }

      return ValidationResult.singleError(errorMessage, fieldName: fieldName);
    }

    return const ValidationResult.success();
  }

  /// Static method to check if a string meets maximum length
  static bool meetsMaxLength(String? value, int maxLength) {
    return value == null || value.length <= maxLength;
  }
}

/// Validator that checks if a value is within a specific length range
class LengthRangeValidator extends BaseValidator<String> {
  const LengthRangeValidator(
    this.minLength,
    this.maxLength, {
    this.message,
    this.includeActualLength = false,
  });

  final int minLength;
  final int maxLength;
  final String? message;
  final bool includeActualLength;

  @override
  ValidationResult validate(String? value, {String? fieldName}) {
    // Allow null/empty values - use RequiredValidator if needed
    if (value == null || value.isEmpty) {
      return const ValidationResult.success();
    }

    final int length = value.length;

    if (length < minLength || length > maxLength) {
      String errorMessage;

      if (message != null) {
        errorMessage = message!;
      } else {
        final String field = fieldName ?? 'Value';
        if (includeActualLength) {
          errorMessage =
              '$field must be between $minLength and $maxLength characters long (current: $length)';
        } else {
          errorMessage =
              '$field must be between $minLength and $maxLength characters long';
        }
      }

      return ValidationResult.singleError(errorMessage, fieldName: fieldName);
    }

    return const ValidationResult.success();
  }

  /// Static method to check if a string is within length range
  static bool isWithinRange(String? value, int minLength, int maxLength) {
    if (value == null) {
      return false;
    }
    final int length = value.length;
    return length >= minLength && length <= maxLength;
  }
}
