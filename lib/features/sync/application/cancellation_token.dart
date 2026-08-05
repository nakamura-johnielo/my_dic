class CancellationToken {
  bool _isCancelled = false;
  String? _reason;
  bool get isCancelled => _isCancelled;
  String? get reason => _reason;
  void cancel([String reason = 'cancelled']) {
    _isCancelled = true;
    _reason = reason;
  }

  void throwIfCancelled() {
    if (_isCancelled) throw SyncCancelledException(_reason ?? 'cancelled');
  }
}

class SyncCancelledException implements Exception {
  const SyncCancelledException(this.reason);
  final String reason;
}
