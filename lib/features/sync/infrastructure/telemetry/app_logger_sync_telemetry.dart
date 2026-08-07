import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_report.dart';
import 'package:my_dic/features/sync/application/port/sync_telemetry.dart';
import 'package:my_dic/features/sync/application/report/sync_reason_codes.dart';
import 'package:my_dic/features/sync/application/report/sync_report_interpreter.dart';
import 'package:my_dic/features/sync/application/report/sync_report_summary.dart';

typedef SyncTelemetryEventLogger = void Function(
  String name,
  Map<String, Object?> context,
);

/// Converts reports to an allowlisted structured log event.
///
/// It never logs the report itself: account identifiers, cursors, payloads,
/// entity/mutation identifiers, and raw errors are deliberately unavailable to
/// the emitted map.
class AppLoggerSyncTelemetry implements SyncTelemetry {
  AppLoggerSyncTelemetry({SyncTelemetryEventLogger? eventLogger})
      : _eventLogger = eventLogger ??
            ((name, context) => AppLogger.event(name, context: context));

  static const eventName = 'sync_cycle_completed';

  final SyncTelemetryEventLogger _eventLogger;

  @override
  Future<void> recordCycleCompleted({
    required String trigger,
    required SyncReport report,
  }) async {
    _eventLogger(eventName, serialize(trigger: trigger, report: report));
  }

  /// Exposed for deterministic security tests and future telemetry adapters.
  Map<String, Object?> serialize({
    required String trigger,
    required SyncReport report,
  }) {
    final summary = SyncReportSummary.fromReport(report);
    return {
      'trigger': _knownTrigger(trigger),
      'duration_ms': summary.duration.inMilliseconds,
      'outcome': _outcome(SyncReportInterpreter().interpret(report)),
      'pushed_count': summary.pushedCount,
      'pulled_count': summary.pulledCount,
      'datasets': [
        for (final entry in report.datasetResults.entries)
          _datasetEvent(entry.key, entry.value),
      ],
    };
  }

  Map<String, Object?> _datasetEvent(
    SyncDataset dataset,
    DatasetSyncResult result,
  ) {
    final event = <String, Object?>{'dataset': dataset.stableId};
    switch (result) {
      case DatasetSyncSuccess():
        event.addAll({
          'result': 'succeeded',
          'pushed_count': result.pushedCount,
          'pulled_count': result.pulledCount,
        });
      case DatasetSyncFailed():
        event.addAll({
          'result': 'failed',
          'error_code': _knownCode(result.errorCode),
          'retryable': result.retryable,
          'cursor_unchanged': result.cursorUnchanged,
        });
      case DatasetSyncSkipped():
        event.addAll({
          'result': 'skipped',
          'error_code': _knownCode(result.reason),
        });
      case DatasetSyncCancelled():
        event.addAll({
          'result': 'cancelled',
          'error_code': _knownCode(result.reason),
        });
    }
    return event;
  }

  String _knownTrigger(String value) =>
      _triggers.contains(value) ? value : 'unknown';

  String _knownCode(String value) => _codes.contains(value) ? value : 'unknown';

  String _outcome(SyncReportOutcome outcome) => switch (outcome) {
        SyncReportOutcome.cancelled => 'cancelled',
        SyncReportOutcome.alreadyRunning => 'already_running',
        SyncReportOutcome.authenticationRequired => 'authentication_required',
        SyncReportOutcome.needsAttention => 'needs_attention',
        SyncReportOutcome.offlineDeferred => 'offline_deferred',
        SyncReportOutcome.retryScheduled => 'retry_scheduled',
        SyncReportOutcome.partialSuccess => 'partial_success',
        SyncReportOutcome.succeeded => 'succeeded',
      };

  static const _triggers = {
    SyncReasonCodes.sessionReady,
    SyncReasonCodes.appResumed,
    SyncReasonCodes.postGuestMigration,
    SyncReasonCodes.manual,
    SyncReasonCodes.retryDue,
  };

  static const _codes = {
    SyncReasonCodes.syncAlreadyRunning,
    SyncReasonCodes.dependencyFailed,
    SyncReasonCodes.handlerUnavailable,
    SyncReasonCodes.sessionChanged,
    SyncReasonCodes.callerCancelled,
    SyncReasonCodes.offline,
    SyncReasonCodes.authRequired,
    SyncReasonCodes.invalidPayload,
    SyncReasonCodes.transientRemoteFailure,
    SyncReasonCodes.handlerException,
  };
}
