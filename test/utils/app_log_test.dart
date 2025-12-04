import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/utils/app_log.dart';

void main() {
  group('AppLog', () {
    group('_format', () {
      test('formats basic message', () {
        // The _format method is private, but we can test the behavior
        // through the public methods by verifying no errors are thrown
        expect(() => AppLog.debug('Scope', 'Test message'), returnsNormally);
      });

      test('handles data in log', () {
        expect(
          () => AppLog.info('Scope', 'Message', data: {'key': 'value', 'num': 42}),
          returnsNormally,
        );
      });

      test('handles error in log', () {
        expect(
          () => AppLog.warn('Scope', 'Warning', error: Exception('test')),
          returnsNormally,
        );
      });

      test('handles error with stack trace', () {
        final stack = StackTrace.current;
        expect(
          () => AppLog.error(
            'Scope',
            'Error',
            error: Exception('test'),
            stack: stack,
          ),
          returnsNormally,
        );
      });
    });

    group('debug', () {
      test('runs without error', () {
        expect(() => AppLog.debug('Test', 'Debug message'), returnsNormally);
      });

      test('accepts data parameter', () {
        expect(
          () => AppLog.debug('Test', 'Debug', data: {'id': 1}),
          returnsNormally,
        );
      });
    });

    group('info', () {
      test('runs without error', () {
        expect(() => AppLog.info('Test', 'Info message'), returnsNormally);
      });

      test('accepts data parameter', () {
        expect(
          () => AppLog.info('Test', 'Info', data: {'name': 'test'}),
          returnsNormally,
        );
      });
    });

    group('warn', () {
      test('runs without error', () {
        expect(() => AppLog.warn('Test', 'Warning message'), returnsNormally);
      });

      test('accepts error parameter', () {
        expect(
          () => AppLog.warn('Test', 'Warning', error: 'Some issue'),
          returnsNormally,
        );
      });

      test('accepts both data and error', () {
        expect(
          () => AppLog.warn(
            'Test',
            'Warning',
            data: {'count': 5},
            error: Exception('oops'),
          ),
          returnsNormally,
        );
      });
    });

    group('error', () {
      test('runs without error', () {
        expect(() => AppLog.error('Test', 'Error message'), returnsNormally);
      });

      test('accepts error parameter', () {
        expect(
          () => AppLog.error('Test', 'Error', error: FormatException('bad')),
          returnsNormally,
        );
      });

      test('accepts stack trace parameter', () {
        try {
          throw Exception('test');
        } catch (e, stack) {
          expect(
            () => AppLog.error('Test', 'Error', error: e, stack: stack),
            returnsNormally,
          );
        }
      });

      test('accepts all parameters', () {
        final stack = StackTrace.current;
        expect(
          () => AppLog.error(
            'Component',
            'Failed operation',
            data: {'attempt': 3, 'max': 5},
            error: StateError('invalid state'),
            stack: stack,
          ),
          returnsNormally,
        );
      });
    });
  });
}
