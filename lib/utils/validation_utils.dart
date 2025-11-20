/// Shared validation helpers for account flows.
class ValidationUtils {
  ValidationUtils._();

  static final RegExp _studentIdPattern = RegExp(r'^\d{4}-\d{4}-IC$');

  /// Returns true when [value] matches the canonical YYYY-XXXX-IC format.
  static bool isValidStudentId(String value) {
    if (value.trim().isEmpty) return false;
    return _studentIdPattern.hasMatch(value.trim().toUpperCase());
  }
}
