import 'model/sync_report.dart';

/// 同期の正しさには関与せず、完了した同期サイクルを観測します。
abstract interface class SyncTelemetry {
  Future<void> recordCycleCompleted({
    required String trigger,
    required SyncReport report,
  });
}

/// テレメトリーを導入しない構成向けの、本番環境で安全な既定値です。
class NoopSyncTelemetry implements SyncTelemetry {
  const NoopSyncTelemetry();

  @override
  Future<void> recordCycleCompleted({
    required String trigger,
    required SyncReport report,
  }) async {}
}

/// 完了サイクル通知を検証するためのインメモリテストダブルです。
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
