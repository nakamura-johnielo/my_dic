import 'model/sync_report.dart';

/// Observes completed sync cycles without participating in sync correctness.
abstract interface class SyncTelemetry {
  Future<void> recordCycleCompleted({
    required String trigger,
    required SyncReport report,
  });
}

/// Production-safe default for compositions that do not install telemetry.
class NoopSyncTelemetry implements SyncTelemetry {
  const NoopSyncTelemetry();

  @override
  Future<void> recordCycleCompleted({
    required String trigger,
    required SyncReport report,
  }) async {}
}

/// In-memory test double for asserting completed-cycle notifications.
class FakeSyncTelemetry implements SyncTelemetry {
  final List<SyncTelemetryCall> calls = [];

  @override
  Future<void> recordCycleCompleted({
    required String trigger,
    required SyncReport report,
  }) async {
    calls.add(SyncTelemetryCall(trigger: trigger, report: report));
  }
}

class SyncTelemetryCall {
  const SyncTelemetryCall({required this.trigger, required this.report});

  final String trigger;
  final SyncReport report;
}
