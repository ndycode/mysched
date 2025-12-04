import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/widgets/instructor_avatar.dart';

void main() {
  group('InstructorAvatar', () {
    testWidgets('displays initials when no avatar URL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorAvatar(
              name: 'John Smith',
              tint: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('JS'), findsOneWidget);
    });

    testWidgets('displays single initial for single name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorAvatar(
              name: 'Madonna',
              tint: Colors.purple,
            ),
          ),
        ),
      );

      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('displays ? for empty name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorAvatar(
              name: '',
              tint: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorAvatar(
              name: 'Test',
              tint: Colors.red,
              size: 50,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InstructorAvatar),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.constraints?.maxWidth, 50);
      expect(container.constraints?.maxHeight, 50);
    });

    testWidgets('applies inverse styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorAvatar(
              name: 'Test User',
              tint: Colors.blue,
              inverse: true,
            ),
          ),
        ),
      );

      expect(find.text('TU'), findsOneWidget);
      // Widget should render without error
    });

    testWidgets('handles whitespace-only avatar URL as empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorAvatar(
              name: 'Test User',
              tint: Colors.blue,
              avatarUrl: '   ',
            ),
          ),
        ),
      );

      // Should fall back to initials
      expect(find.text('TU'), findsOneWidget);
    });

    testWidgets('attempts to load image when avatar URL provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorAvatar(
              name: 'Test User',
              tint: Colors.blue,
              avatarUrl: 'https://example.com/avatar.jpg',
            ),
          ),
        ),
      );

      // Image.network should be attempted
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('uses default size of 28', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorAvatar(
              name: 'Default Size',
              tint: Colors.orange,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InstructorAvatar),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.constraints?.maxWidth, 28);
      expect(container.constraints?.maxHeight, 28);
    });

    testWidgets('handles unicode names correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorAvatar(
              name: 'José García',
              tint: Colors.teal,
            ),
          ),
        ),
      );

      expect(find.text('JG'), findsOneWidget);
    });
  });
}
