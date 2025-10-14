import '../base_validator.dart';
import '../validation_result.dart';

/// Validator that checks if a value matches a regular expression pattern
class RegexValidator extends BaseValidator<String> {
  const RegexValidator(
    this.pattern, {
    this.message = 'Value does not match the required format',
    this.shouldMatch = true,
  });

  /// Create a RegexValidator from a RegExp object
  RegexValidator.fromRegExp(
    RegExp regExp, {
    this.message = 'Value does not match the required format',
    this.shouldMatch = true,
  }) : pattern = regExp.pattern;

  final String pattern;
  final String message;
  final bool shouldMatch; // true = must match, false = must NOT match

  RegExp get _regExp => RegExp(pattern);

  @override
  ValidationResult validate(String? value, {String? fieldName}) {
    // Allow null/empty values - use RequiredValidator if needed
    if (value == null || value.isEmpty) {
      return const ValidationResult.success();
    }

    final bool matches = _regExp.hasMatch(value);
    final bool isValid = shouldMatch ? matches : !matches;

    if (!isValid) {
      final String errorMessage = fieldName != null
          ? '$fieldName: $message'
          : message;
      return ValidationResult.singleError(errorMessage, fieldName: fieldName);
    }

    return const ValidationResult.success();
  }

  /// Static method to check if a string matches a pattern
  static bool matches(String? value, String pattern) {
    if (value == null) {
      return false;
    }
    return RegExp(pattern).hasMatch(value);
  }

  /// Static method to check if a string matches a RegExp
  static bool matchesRegExp(String? value, RegExp regExp) {
    if (value == null) {
      return false;
    }
    return regExp.hasMatch(value);
  }
}

/// Predefined common regex validators
class CommonRegexValidators {
  CommonRegexValidators._();

  /// Phone number validator (international format)
  static const RegexValidator phoneNumber = RegexValidator(
    r'^\+?[1-9]\d{1,14}$',
    message: 'Please enter a valid phone number',
  );

  /// Phone number validator (German format)
  static const RegexValidator phoneNumberDE = RegexValidator(
    r'^(\+49|0)[1-9]\d{1,14}$',
    message: 'Please enter a valid German phone number',
  );

  /// URL validator (basic)
  static const RegexValidator url = RegexValidator(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    message: 'Please enter a valid URL',
  );

  /// Credit card number validator (basic format check)
  static const RegexValidator creditCard = RegexValidator(
    r'^\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}$',
    message: 'Please enter a valid credit card number',
  );

  /// German postal code validator
  static const RegexValidator germanPostalCode = RegexValidator(
    r'^\d{5}$',
    message: 'Please enter a valid German postal code (5 digits)',
  );

  /// US postal code validator (ZIP or ZIP+4)
  static const RegexValidator usPostalCode = RegexValidator(
    r'^\d{5}(-\d{4})?$',
    message: 'Please enter a valid US postal code',
  );

  /// Username validator (alphanumeric, underscore, hyphen)
  static const RegexValidator username = RegexValidator(
    r'^[a-zA-Z0-9_-]{3,20}$',
    message:
        'Username must be 3-20 characters long and contain only letters, numbers, underscore, or hyphen',
  );

  /// Hex color validator (#RGB or #RRGGBB)
  static const RegexValidator hexColor = RegexValidator(
    r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$',
    message: 'Please enter a valid hex color code',
  );

  /// IPv4 address validator
  static const RegexValidator ipv4 = RegexValidator(
    r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    message: 'Please enter a valid IPv4 address',
  );

  /// Alphanumeric only validator
  static const RegexValidator alphanumeric = RegexValidator(
    r'^[a-zA-Z0-9]+$',
    message: 'Value must contain only letters and numbers',
  );

  /// Letters only validator
  static const RegexValidator lettersOnly = RegexValidator(
    r'^[a-zA-Z]+$',
    message: 'Value must contain only letters',
  );

  /// Numbers only validator
  static const RegexValidator numbersOnly = RegexValidator(
    r'^\d+$',
    message: 'Value must contain only numbers',
  );

  /// No special characters validator
  static const RegexValidator noSpecialChars = RegexValidator(
    r'^[a-zA-Z0-9\s]+$',
    message: 'Value must not contain special characters',
  );

  /// No whitespace validator
  static const RegexValidator noWhitespace = RegexValidator(
    r'^\S+$',
    message: 'Value must not contain whitespace',
  );
}
