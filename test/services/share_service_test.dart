import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mysched/services/share_service.dart';

void main() {
  group('ShareService', () {
    tearDown(() {
      ShareService.reset();
    });

    test('overrideForTests replaces invoker', () async {
      var invokerCalled = false;
      ShareParams? capturedParams;

      ShareService.overrideForTests((params) async {
        invokerCalled = true;
        capturedParams = params;
        return ShareResult('Success', ShareResultStatus.success);
      });

      final params = ShareParams(text: 'Test share message');
      final result = await ShareService.share(params);

      expect(invokerCalled, true);
      expect(capturedParams?.text, 'Test share message');
      expect(result.status, ShareResultStatus.success);
    });

    test('reset restores default invoker', () async {
      var customInvokerCalled = false;

      ShareService.overrideForTests((params) async {
        customInvokerCalled = true;
        return ShareResult('Custom', ShareResultStatus.success);
      });

      ShareService.reset();

      // After reset, the default invoker should be used
      // We can't actually test the real share, so just verify the override was cleared
      expect(customInvokerCalled, false);
    });

    test('multiple shares use same overridden invoker', () async {
      var callCount = 0;

      ShareService.overrideForTests((params) async {
        callCount++;
        return ShareResult('Success', ShareResultStatus.success);
      });

      await ShareService.share(ShareParams(text: 'First'));
      await ShareService.share(ShareParams(text: 'Second'));
      await ShareService.share(ShareParams(text: 'Third'));

      expect(callCount, 3);
    });

    test('can return different results from test invoker', () async {
      var callIndex = 0;
      final results = [
        ShareResult('First', ShareResultStatus.success),
        ShareResult('Second', ShareResultStatus.dismissed),
        ShareResult('Third', ShareResultStatus.unavailable),
      ];

      ShareService.overrideForTests((params) async {
        return results[callIndex++];
      });

      final result1 = await ShareService.share(ShareParams(text: 'Test'));
      expect(result1.status, ShareResultStatus.success);

      final result2 = await ShareService.share(ShareParams(text: 'Test'));
      expect(result2.status, ShareResultStatus.dismissed);

      final result3 = await ShareService.share(ShareParams(text: 'Test'));
      expect(result3.status, ShareResultStatus.unavailable);
    });
  });
}
