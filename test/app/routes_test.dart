import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/app/routes.dart';

void main() {
  group('AppRoutes', () {
    test('splash route is correct', () {
      expect(AppRoutes.splash, '/splash');
    });

    test('login route is correct', () {
      expect(AppRoutes.login, '/login');
    });

    test('register route is correct', () {
      expect(AppRoutes.register, '/register');
    });

    test('verify route is correct', () {
      expect(AppRoutes.verify, '/verify');
    });

    test('app route is correct', () {
      expect(AppRoutes.app, '/app');
    });

    test('reminders route is correct', () {
      expect(AppRoutes.reminders, '/reminders');
    });

    test('account route is correct', () {
      expect(AppRoutes.account, '/account');
    });

    test('changeEmail route is correct', () {
      expect(AppRoutes.changeEmail, '/account/change-email');
    });

    test('changePassword route is correct', () {
      expect(AppRoutes.changePassword, '/account/change-password');
    });

    test('deleteAccount route is correct', () {
      expect(AppRoutes.deleteAccount, '/account/delete');
    });

    test('styleGuide route is correct', () {
      expect(AppRoutes.styleGuide, '/style-guide');
    });

    test('all account routes start with /account', () {
      expect(AppRoutes.account.startsWith('/account'), true);
      expect(AppRoutes.changeEmail.startsWith('/account'), true);
      expect(AppRoutes.changePassword.startsWith('/account'), true);
      expect(AppRoutes.deleteAccount.startsWith('/account'), true);
    });
  });
}
