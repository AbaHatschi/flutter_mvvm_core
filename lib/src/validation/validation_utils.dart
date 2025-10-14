import 'base_validator.dart';
import 'validation_result.dart';
import 'validators/email_validator.dart';
import 'validators/length_validator.dart';
import 'validators/password_validator.dart';
import 'validators/regex_validator.dart';
import 'validators/required_validator.dart';

/// Utility class for common validation scenarios and helper methods
class ValidationUtils {
  ValidationUtils._();

  // Common validators for quick access
  static const RequiredValidator<String> required = RequiredValidator<String>();
  static const EmailValidator email = EmailValidator();
  static const PasswordValidator password = PasswordValidator();
  static const PasswordValidator simplePassword = PasswordValidator(
    requirements: PasswordRequirements.simple,
  );
  static const PasswordValidator moderatePassword = PasswordValidator(
    requirements: PasswordRequirements.moderate,
  );

  /// Validate a required email field
  static ValidationResult validateRequiredEmail(
    String? value, {
    String? fieldName,
  }) {
    return const CombinedValidator<String>(<BaseValidator<String>>[
      required,
      email,
    ]).validate(value, fieldName: fieldName);
  }

  /// Validate a required password field
  static ValidationResult validateRequiredPassword(
    String? value, {
    String? fieldName,
    PasswordRequirements requirements = PasswordRequirements.strong,
  }) {
    final PasswordValidator passwordValidator = PasswordValidator(
      requirements: requirements,
    );
    return CombinedValidator<String>(<BaseValidator<String>>[
      required,
      passwordValidator,
    ]).validate(value, fieldName: fieldName);
  }

  /// Validate password confirmation
  static ValidationResult validatePasswordConfirmation(
    String? password,
    String? confirmation, {
    String? fieldName,
  }) {
    if (password != confirmation) {
      final String errorMessage = fieldName != null
          ? '$fieldName must match the password'
          : 'Password confirmation must match the password';
      return ValidationResult.singleError(errorMessage, fieldName: fieldName);
    }
    return const ValidationResult.success();
  }

  /// Validate a required field with minimum length
  static ValidationResult validateRequiredMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    final MinLengthValidator minLengthValidator = MinLengthValidator(minLength);
    return CombinedValidator<String>(<BaseValidator<String>>[
      required,
      minLengthValidator,
    ]).validate(value, fieldName: fieldName);
  }

  /// Validate a required field with length range
  static ValidationResult validateRequiredLengthRange(
    String? value,
    int minLength,
    int maxLength, {
    String? fieldName,
  }) {
    final LengthRangeValidator lengthValidator = LengthRangeValidator(
      minLength,
      maxLength,
    );
    return CombinedValidator<String>(<BaseValidator<String>>[
      required,
      lengthValidator,
    ]).validate(value, fieldName: fieldName);
  }

  /// Validate a phone number (optional)
  static ValidationResult validatePhoneNumber(
    String? value, {
    String? fieldName,
  }) {
    return CommonRegexValidators.phoneNumber.validate(
      value,
      fieldName: fieldName,
    );
  }

  /// Validate a required phone number
  static ValidationResult validateRequiredPhoneNumber(
    String? value, {
    String? fieldName,
  }) {
    return const CombinedValidator<String>(<BaseValidator<String>>[
      required,
      CommonRegexValidators.phoneNumber,
    ]).validate(value, fieldName: fieldName);
  }

  /// Validate a URL (optional)
  static ValidationResult validateUrl(String? value, {String? fieldName}) {
    return CommonRegexValidators.url.validate(value, fieldName: fieldName);
  }

  /// Validate a required URL
  static ValidationResult validateRequiredUrl(
    String? value, {
    String? fieldName,
  }) {
    return const CombinedValidator<String>(<BaseValidator<String>>[
      required,
      CommonRegexValidators.url,
    ]).validate(value, fieldName: fieldName);
  }

  /// Validate multiple fields and return combined result
  static ValidationResult validateMultipleFields(
    Map<String, ValidationResult> fieldResults,
  ) {
    final List<String> allErrors = <String>[];

    for (final MapEntry<String, ValidationResult> entry
        in fieldResults.entries) {
      final ValidationResult result = entry.value;
      if (!result.isValid) {
        allErrors.addAll(result.errors);
      }
    }

    if (allErrors.isNotEmpty) {
      return ValidationResult.failure(allErrors);
    }

    return const ValidationResult.success();
  }

  /// Validate a form with field validators
  static ValidationResult validateForm(
    Map<String, (String?, BaseValidator<String>)> fields,
  ) {
    final Map<String, ValidationResult> results = <String, ValidationResult>{};

    for (final MapEntry<String, (String?, BaseValidator<String>)> entry
        in fields.entries) {
      final String fieldName = entry.key;
      final (String? value, BaseValidator<String> validator) = entry.value;
      results[fieldName] = validator.validate(value, fieldName: fieldName);
    }

    return validateMultipleFields(results);
  }

  /// Quick validation helpers for common scenarios

  /// Check if email is valid (null-safe)
  static bool isValidEmail(String? email) {
    return EmailValidator.isValidEmail(email);
  }

  /// Check if string meets minimum length (null-safe)
  static bool meetsMinLength(String? value, int minLength) {
    return MinLengthValidator.meetsMinLength(value, minLength);
  }

  /// Check if string is within length range (null-safe)
  static bool isWithinLengthRange(String? value, int minLength, int maxLength) {
    return LengthRangeValidator.isWithinRange(value, minLength, maxLength);
  }

  /// Check if string matches regex pattern (null-safe)
  static bool matchesPattern(String? value, String pattern) {
    return RegexValidator.matches(value, pattern);
  }

  /// Get password strength
  static PasswordStrength getPasswordStrength(String? password) {
    return PasswordValidator.checkPasswordStrength(password);
  }

  /// Sanitize input by trimming whitespace
  static String? sanitizeInput(String? input) {
    return input?.trim();
  }

  /// Remove all whitespace from input
  static String? removeWhitespace(String? input) {
    return input?.replaceAll(RegExp(r'\s+'), '');
  }

  /// Normalize phone number (remove spaces, hyphens, etc.)
  static String? normalizePhoneNumber(String? phoneNumber) {
    return phoneNumber?.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Format validation errors for display
  static String formatValidationErrors(
    ValidationResult result, {
    String separator = '\n',
  }) {
    if (result.isValid) {
      return '';
    }
    return result.errors.join(separator);
  }

  /// Create a custom validator that combines multiple validators
  static BaseValidator<T> combine<T>(List<BaseValidator<T>> validators) {
    return CombinedValidator<T>(validators);
  }

  /// Create a conditional validator that only validates if condition is true
  static BaseValidator<T> conditional<T>(
    bool Function() condition,
    BaseValidator<T> validator,
  ) {
    return ConditionalValidator<T>(condition, validator);
  }
}

/// Validator that only validates if a condition is met
class ConditionalValidator<T> extends BaseValidator<T> {
  const ConditionalValidator(this.condition, this.validator);

  final bool Function() condition;
  final BaseValidator<T> validator;

  @override
  ValidationResult validate(T? value, {String? fieldName}) {
    if (!condition()) {
      return const ValidationResult.success();
    }
    return validator.validate(value, fieldName: fieldName);
  }
}
