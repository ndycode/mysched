import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/profile_cache.dart';

void main() {
  group('ProfileSummary', () {
    test('initial returns fallback for empty profile', () {
      const profile = ProfileSummary();
      expect(profile.initial(), 'M');
    });

    test('initial uses name when available', () {
      const profile = ProfileSummary(name: 'John Doe');
      expect(profile.initial(), 'J');
    });

    test('initial uses email when name is empty', () {
      const profile = ProfileSummary(email: 'jane.doe@example.com');
      expect(profile.initial(), 'J');
    });

    test('initial prefers name over email', () {
      const profile = ProfileSummary(
        name: 'Alice Smith',
        email: 'bob@example.com',
      );
      expect(profile.initial(), 'A');
    });

    test('initial handles whitespace in name', () {
      const profile = ProfileSummary(name: '   John   ');
      expect(profile.initial(), 'J');
    });

    test('initial uses custom fallback', () {
      const profile = ProfileSummary();
      expect(profile.initial(fallback: 'X'), 'X');
    });

    test('initial converts to uppercase', () {
      const profile = ProfileSummary(name: 'alice');
      expect(profile.initial(), 'A');
    });

    group('copyWith', () {
      test('creates copy with new name', () {
        const original = ProfileSummary(name: 'Original');
        final copy = original.copyWith(name: 'New Name');

        expect(copy.name, 'New Name');
        expect(original.name, 'Original');
      });

      test('creates copy with new email', () {
        const original = ProfileSummary(email: 'old@example.com');
        final copy = original.copyWith(email: 'new@example.com');

        expect(copy.email, 'new@example.com');
        expect(original.email, 'old@example.com');
      });

      test('creates copy with new avatarUrl', () {
        const original = ProfileSummary();
        final copy = original.copyWith(avatarUrl: 'https://example.com/avatar.jpg');

        expect(copy.avatarUrl, 'https://example.com/avatar.jpg');
        expect(original.avatarUrl, isNull);
      });

      test('creates copy with new updatedAt', () {
        const original = ProfileSummary();
        final now = DateTime.now();
        final copy = original.copyWith(updatedAt: now);

        expect(copy.updatedAt, now);
        expect(original.updatedAt, isNull);
      });

      test('preserves unmodified values', () {
        final original = ProfileSummary(
          name: 'Test User',
          email: 'test@example.com',
          avatarUrl: 'https://example.com/avatar.jpg',
          updatedAt: DateTime(2024, 1, 1),
        );

        final copy = original.copyWith(name: 'New Name');

        expect(copy.name, 'New Name');
        expect(copy.email, original.email);
        expect(copy.avatarUrl, original.avatarUrl);
        expect(copy.updatedAt, original.updatedAt);
      });
    });
  });

  group('ProfileCache', () {
    setUp(() {
      ProfileCache.clear();
    });

    tearDown(() {
      ProfileCache.clear();
    });

    test('clear resets cache', () {
      ProfileCache.clear();
      expect(ProfileCache.notifier.value, isNull);
      expect(ProfileCache.lastUpdated(), isNull);
    });
  });
}
