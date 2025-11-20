typedef ExportJob = Future<void> Function();
typedef ConnectivityCheck = Future<bool> Function();

class ExportQueue {
  ExportQueue({required this.connectivity});

  final ConnectivityCheck connectivity;
  final List<ExportJob> _pending = <ExportJob>[];
  bool _flushing = false;

  void enqueue(ExportJob job) => _pending.add(job);

  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      if (!await connectivity()) return;
      while (_pending.isNotEmpty) {
        final job = _pending.first;
        try {
          await job();
          _pending.removeAt(0);
        } catch (_) {
          break;
        }
      }
    } finally {
      _flushing = false;
    }
  }

  int get pending => _pending.length;
}
