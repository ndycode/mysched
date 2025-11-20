import 'dart:io';

void main(List<String> args) {
  final buffer = StringBuffer()
    ..writeln('=== MySched Developer Guide ===')
    ..writeln()
    ..writeln('Build & Test Commands')
    ..writeln('  flutter pub get')
    ..writeln('  dart format lib test')
    ..writeln('  flutter analyze')
    ..writeln('  flutter test --coverage')
    ..writeln('  flutter run --profile')
    ..writeln()
    ..writeln('Lint & Style Conventions')
    ..writeln('  - Flutter style guide (2-space indent, trailing commas).')
    ..writeln('  - Prefer final locals and Theme.of(context) for colors.')
    ..writeln('  - Route telemetry through AnalyticsService; avoid print.')
    ..writeln()
    ..writeln('UI Kit Components')
    ..writeln(
        '  - AppScaffold - adds analytics, motion, and semantics to pages.')
    ..writeln(
        '  - PrimaryButton / SecondaryButton - branded CTAs with haptics.')
    ..writeln('  - IconTonalButton - tonal action for neutral contexts.')
    ..writeln('  - AppBarX - lightweight AppBar wrapper with common styling.')
    ..writeln(
        '  - Layout primitives (containers, layout) - spacing tokens & cards.');

  stdout.write(buffer.toString());
}
