import 'package:flutter_test/flutter_test.dart';
import 'package:mysched/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AuthService.overrideProfileUpdater(
      ({required String fullName, required String studentId}) async {},
    );
  });

  tearDown(() {
    AuthService.overrideProfileUpdater(null);
  });

  test('normalizes values before invoking override', () async {
    final calls = <Map<String, String>>[];
    AuthService.overrideProfileUpdater((
        {required String fullName, required String studentId}) async {
      calls.add({'name': fullName, 'id': studentId});
    });

    await AuthService.instance.updateProfileDetails(
      fullName: '  Maria  Dela Cruz ',
      studentId: '2025-0001-ic',
    );

    expect(calls, hasLength(1));
    expect(calls.first['name'], 'Maria  Dela Cruz');
    expect(calls.first['id'], '2025-0001-IC');
  });

  test('throws when name is too short', () async {
    expect(
      () => AuthService.instance.updateProfileDetails(
        fullName: 'Al',
        studentId: '2025-0001-IC',
      ),
      throwsA(predicate((error) =>
          error.toString().toLowerCase().contains('profile_invalid_name'))),
    );
  });

  test('throws when student id format is invalid', () async {
    expect(
      () => AuthService.instance.updateProfileDetails(
        fullName: 'Valid Name',
        studentId: 'BAD-ID',
      ),
      throwsA(predicate((error) => error
          .toString()
          .toLowerCase()
          .contains('profile_invalid_student_id'))),
    );
  });
}
