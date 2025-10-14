import '../base_validator.dart';
import '../validation_result.dart';

/// Configuration class for password validation requirements
class PasswordRequirements {
  const PasswordRequirements({
    this.minLength = 8,
    this.maxLength,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireDigits = true,
    this.requireSpecialChars = true,
    this.specialChars = r'!@#$%^&*(),.?":{}|<>',
    this.allowSpaces = false,
  });

  final int minLength;
  final int? maxLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireDigits;
  final bool requireSpecialChars;
  final String specialChars;
  final bool allowSpaces;

  /// Default strong password requirements
  static const PasswordRequirements strong = PasswordRequirements();

  /// Moderate password requirements
  static const PasswordRequirements moderate = PasswordRequirements(
    minLength: 6,
    requireSpecialChars: false,
  );

  /// Simple password requirements
  static const PasswordRequirements simple = PasswordRequirements(
    minLength: 4,
    requireUppercase: false,
    requireLowercase: false,
    requireDigits: false,
    requireSpecialChars: false,
  );
}

/// Validator that checks if a string meets password requirements
class PasswordValidator extends BaseValidator<String> {
  const PasswordValidator({
    this.requirements = PasswordRequirements.strong,
    this.message = 'Password does not meet requirements',
  });

  final PasswordRequirements requirements;
  final String message;

  @override
  ValidationResult validate(String? value, {String? fieldName}) {
    // Allow null/empty values - use RequiredValidator if needed
    if (value == null || value.isEmpty) {
      return const ValidationResult.success();
    }

    final List<String> errors = <String>[];
    final String field = fieldName ?? 'Password';

    // Check minimum length
    if (value.length < requirements.minLength) {
      errors.add(
        '$field must be at least ${requirements.minLength} characters long',
      );
    }

    // Check maximum length
    if (requirements.maxLength != null &&
        value.length > requirements.maxLength!) {
      errors.add('$field must not exceed ${requirements.maxLength} characters');
    }

    // Check for spaces if not allowed
    if (!requirements.allowSpaces && value.contains(' ')) {
      errors.add('$field must not contain spaces');
    }

    // Check for uppercase letters
    if (requirements.requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      errors.add('$field must contain at least one uppercase letter');
    }

    // Check for lowercase letters
    if (requirements.requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      errors.add('$field must contain at least one lowercase letter');
    }

    // Check for digits
    if (requirements.requireDigits && !value.contains(RegExp(r'[0-9]'))) {
      errors.add('$field must contain at least one digit');
    }

    // Check for special characters
    if (requirements.requireSpecialChars) {
      final RegExp specialCharsRegex = RegExp(
        '[${RegExp.escape(requirements.specialChars)}]',
      );
      if (!value.contains(specialCharsRegex)) {
        errors.add(
          '$field must contain at least one special character (${requirements.specialChars})',
        );
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors, fieldName: fieldName);
    }

    return const ValidationResult.success();
  }

  /// Static method to check password strength
  static PasswordStrength checkPasswordStrength(String? password) {
    if (password == null || password.isEmpty) {
      return PasswordStrength.veryWeak;
    }

    int score = 0;

    // Length scoring
    if (password.length >= 8) {
      score += 2;
    } else if (password.length >= 6) {
      score += 1;
    }

    // Character variety scoring
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 1;
    }
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
    }
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 1;
    }
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
    }

    // Additional length bonus
    if (password.length >= 12) {
      score += 1;
    }
    if (password.length >= 16) {
      score += 1;
    }

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.veryWeak;
      case 2:
      case 3:
        return PasswordStrength.weak;
      case 4:
      case 5:
        return PasswordStrength.moderate;
      case 6:
      case 7:
        return PasswordStrength.strong;
      default:
        return PasswordStrength.veryStrong;
    }
  }
}

/// Enum representing password strength levels
enum PasswordStrength {
  veryWeak,
  weak,
  moderate,
  strong,
  veryStrong;

  /// Get a user-friendly description of the password strength
  String get description {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 'Very Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.moderate:
        return 'Moderate';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  /// Get a color suggestion for UI representation
  String get colorHex {
    switch (this) {
      case PasswordStrength.veryWeak:
        return '#FF0000'; // Red
      case PasswordStrength.weak:
        return '#FF6600'; // Orange
      case PasswordStrength.moderate:
        return '#FFCC00'; // Yellow
      case PasswordStrength.strong:
        return '#66CC00'; // Light Green
      case PasswordStrength.veryStrong:
        return '#00CC00'; // Green
    }
  }
}
