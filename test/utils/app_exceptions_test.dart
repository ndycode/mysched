import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/utils/app_exceptions.dart';

void main() {
  group('NotAuthenticatedException', () {
    test('has default message', () {
      const exception = NotAuthenticatedException();
      expect(exception.message, 'Not authenticated');
      expect(exception.toString(), 'NotAuthenticatedException: Not authenticated');
    });

    test('accepts custom message', () {
      const exception = NotAuthenticatedException('Session expired');
      expect(exception.message, 'Session expired');
      expect(exception.toString(), 'NotAuthenticatedException: Session expired');
    });
  });

  group('NetworkException', () {
    test('has default message', () {
      const exception = NetworkException();
      expect(exception.message, 'Network error');
      expect(exception.toString(), 'NetworkException: Network error');
    });

    test('accepts custom message', () {
      const exception = NetworkException('Connection timed out');
      expect(exception.message, 'Connection timed out');
      expect(exception.toString(), 'NetworkException: Connection timed out');
    });
  });

  group('ValidationException', () {
    test('stores message', () {
      const exception = ValidationException('Invalid input');
      expect(exception.message, 'Invalid input');
      expect(exception.field, isNull);
      expect(exception.toString(), 'ValidationException: Invalid input');
    });

    test('stores field name', () {
      const exception = ValidationException('Email is required', field: 'email');
      expect(exception.message, 'Email is required');
      expect(exception.field, 'email');
    });
  });

  group('NotFoundException', () {
    test('has default message', () {
      const exception = NotFoundException();
      expect(exception.message, 'Resource not found');
      expect(exception.toString(), 'NotFoundException: Resource not found');
    });

    test('accepts custom message', () {
      const exception = NotFoundException('User not found');
      expect(exception.message, 'User not found');
      expect(exception.toString(), 'NotFoundException: User not found');
    });
  });

  group('RateLimitException', () {
    test('has default message', () {
      const exception = RateLimitException();
      expect(exception.message, 'Rate limit exceeded');
      expect(exception.retryAfter, isNull);
      expect(exception.toString(), 'RateLimitException: Rate limit exceeded');
    });

    test('accepts custom message and retry duration', () {
      const exception = RateLimitException(
        'Too many requests',
        Duration(seconds: 30),
      );
      expect(exception.message, 'Too many requests');
      expect(exception.retryAfter, const Duration(seconds: 30));
    });
  });

  group('ConflictException', () {
    test('has default message', () {
      const exception = ConflictException();
      expect(exception.message, 'Resource conflict');
      expect(exception.toString(), 'ConflictException: Resource conflict');
    });

    test('accepts custom message', () {
      const exception = ConflictException('Email already exists');
      expect(exception.message, 'Email already exists');
      expect(exception.toString(), 'ConflictException: Email already exists');
    });
  });
}
