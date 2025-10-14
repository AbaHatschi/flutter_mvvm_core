import '../base_validator.dart';
import '../validation_result.dart';

/// Validator that checks if a string is a valid email address
class EmailValidator extends BaseValidator<String> {
  const EmailValidator({this.message = 'Please enter a valid email address'});

  final String message;

  /// Regular expression for email validation
  /// Based on RFC 5322 specification (simplified)
  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  @override
  ValidationResult validate(String? value, {String? fieldName}) {
    // Allow null/empty values - use RequiredValidator if needed
    if (value == null || value.trim().isEmpty) {
      return const ValidationResult.success();
    }

    final bool isValid = _emailRegExp.hasMatch(value.trim());

    if (!isValid) {
      final String errorMessage = fieldName != null
          ? '$fieldName must be a valid email address'
          : message;
      return ValidationResult.singleError(errorMessage, fieldName: fieldName);
    }

    return const ValidationResult.success();
  }

  /// Static method to check if a string is a valid email
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return false;
    }
    return _emailRegExp.hasMatch(email.trim());
  }
}
