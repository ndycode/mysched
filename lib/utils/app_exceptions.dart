/// Thrown when a user is not authenticated but an action requires auth.
class NotAuthenticatedException implements Exception {
  const NotAuthenticatedException([this.message = 'Not authenticated']);

  final String message;

  @override
  String toString() => 'NotAuthenticatedException: $message';
}

/// Thrown when a network operation fails.
class NetworkException implements Exception {
  const NetworkException([this.message = 'Network error']);

  final String message;
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when validation fails.
class ValidationException implements Exception {
  const ValidationException(this.message, {this.field});

  final String message;
  final String? field;

  @override
  String toString() => 'ValidationException: $message';
}

/// Thrown when a resource is not found.
class NotFoundException implements Exception {
  const NotFoundException([this.message = 'Resource not found']);

  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}

/// Thrown when a rate limit is exceeded.
class RateLimitException implements Exception {
  const RateLimitException([this.message = 'Rate limit exceeded', this.retryAfter]);

  final String message;
  final Duration? retryAfter;

  @override
  String toString() => 'RateLimitException: $message';
}

/// Thrown when an operation conflicts with existing data.
class ConflictException implements Exception {
  const ConflictException([this.message = 'Resource conflict']);

  final String message;

  @override
  String toString() => 'ConflictException: $message';
}

/// Thrown when authentication credentials are invalid.
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException([this.message = 'Invalid email or password']);

  final String message;

  @override
  String toString() => 'InvalidCredentialsException: $message';
}

/// Thrown when email verification is required before login.
class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException(this.email, [this.message = 'Email not verified']);

  final String email;
  final String message;

  @override
  String toString() => 'EmailNotVerifiedException: $message';
}

/// Thrown when a network timeout occurs.
class TimeoutException implements Exception {
  const TimeoutException([this.message = 'Request timed out']);

  final String message;

  @override
  String toString() => 'TimeoutException: $message';
}
