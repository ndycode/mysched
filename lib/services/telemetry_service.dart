typedef TelemetryRecorder = void Function(
  String name,
  Map<String, dynamic>? data,
);

class TelemetryService {
  TelemetryService._();

  static final TelemetryService instance = TelemetryService._();

  static TelemetryRecorder? _recorder;

  static void install(TelemetryRecorder recorder) {
    _recorder = recorder;
  }

  static void ensureRecorder(TelemetryRecorder recorder) {
    _recorder ??= recorder;
  }

  void recordEvent(String name, {Map<String, dynamic>? data}) {
    final target = _recorder;
    if (target != null) {
      target(name, data);
    }
  }

  void logEvent(String name, {Map<String, dynamic>? data}) {
    recordEvent(name, data: data);
  }

  void logError(
    String name, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? data,
  }) {
    final payload = <String, dynamic>{
      if (data != null) ...data,
      if (error != null) 'error': error.toString(),
      if (stack != null) 'stack': stack.toString(),
    };
    recordEvent(name, data: payload.isEmpty ? null : payload);
  }

  static void overrideForTests(TelemetryRecorder recorder) {
    _recorder = recorder;
  }

  static void reset() {
    _recorder = null;
  }
}
