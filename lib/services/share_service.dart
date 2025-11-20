import 'package:share_plus/share_plus.dart';

typedef ShareParamsInvoker = Future<ShareResult> Function(ShareParams params);

class ShareService {
  ShareService._();

  static ShareParamsInvoker _invoker = _defaultInvoker;

  static Future<ShareResult> share(ShareParams params) {
    return _invoker(params);
  }

  static void overrideForTests(ShareParamsInvoker invoker) {
    _invoker = invoker;
  }

  static void reset() {
    _invoker = _defaultInvoker;
  }

  static Future<ShareResult> _defaultInvoker(ShareParams params) {
    return SharePlus.instance.share(params);
  }
}
