/// Shared validation helpers for account flows.
class ValidationUtils {
  ValidationUtils._();

  static final RegExp _studentIdPattern = RegExp(r'^\d{4}-\d{4}-IC$');
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Returns true when [value] matches the canonical YYYY-XXXX-IC format.
  static bool isValidStudentId(String value) {
    if (value.trim().isEmpty) return false;
    return _studentIdPattern.hasMatch(value.trim().toUpperCase());
  }

  /// Returns true when [value] is a valid email address format.
  static bool isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return _emailPattern.hasMatch(value.trim());
  }

  /// Simple check that [value] contains '@'. Use [isValidEmail] for strict validation.
  static bool looksLikeEmail(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return value.contains('@');
  }
}
