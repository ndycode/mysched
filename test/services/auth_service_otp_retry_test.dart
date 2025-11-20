import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/auth_service.dart';

void main() {
  group('AuthService.shouldRetryOtpError', () {
    test('treats invalid, expired, or missing data as non-retriable', () {
      expect(
        AuthService.shouldRetryOtpError(Exception('Invalid OTP provided')),
        isFalse,
      );
      expect(
        AuthService.shouldRetryOtpError(
            Exception('Token expired, request a new code')),
        isFalse,
      );
      expect(
        AuthService.shouldRetryOtpError(Exception('verify_missing_email')),
        isFalse,
      );
    });

    test('treats rate limiting or blocks as non-retriable', () {
      expect(
        AuthService.shouldRetryOtpError(Exception('Rate limit exceeded')),
        isFalse,
      );
      expect(
        AuthService.shouldRetryOtpError(
            Exception('Block due to repeated attempts')),
        isFalse,
      );
    });

    test('allows retries for transport or unknown errors', () {
      expect(
        AuthService.shouldRetryOtpError(
          Exception('SocketException: host lookup failed'),
        ),
        isTrue,
      );
      expect(
        AuthService.shouldRetryOtpError(Exception('Unexpected service outage')),
        isTrue,
      );
    });
  });
}
