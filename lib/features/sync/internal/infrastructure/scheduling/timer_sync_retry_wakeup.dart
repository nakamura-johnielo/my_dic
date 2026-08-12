import 'dart:async';

import 'package:my_dic/features/sync/port/sync_retry_wakeup.dart';

/// In-process retry wake-up adapter. It intentionally does not implement a
/// second retry policy: [dueAt] is supplied by the persisted queue.
class TimerSyncRetryWakeup implements ISyncRetryWakeup {
  TimerSyncRetryWakeup({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Map<String, _ScheduledWakeup> _wakeups = {};
  bool _disposed = false;

  @override
  void arm({
    required String accountId,
    required DateTime dueAt,
    required void Function() onDue,
  }) {
    if (_disposed) return;
    final utcDueAt = dueAt.toUtc();
    final existing = _wakeups[accountId];
    if (existing != null && !utcDueAt.isBefore(existing.dueAt)) return;
    existing?.timer.cancel();

    late final Timer timer;
    timer = Timer(_nonNegativeDelay(utcDueAt), () {
      final current = _wakeups[accountId];
      if (identical(current?.timer, timer)) {
        _wakeups.remove(accountId);
        onDue();
      }
    });
    _wakeups[accountId] = _ScheduledWakeup(utcDueAt, timer);
  }

  Duration _nonNegativeDelay(DateTime dueAt) {
    final delay = dueAt.difference(_clock().toUtc());
    return delay.isNegative ? Duration.zero : delay;
  }

  @override
  void cancel(String accountId) => _wakeups.remove(accountId)?.timer.cancel();

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final wakeup in _wakeups.values) {
      wakeup.timer.cancel();
    }
    _wakeups.clear();
  }
}

class _ScheduledWakeup {
  const _ScheduledWakeup(this.dueAt, this.timer);
  final DateTime dueAt;
  final Timer timer;
}
