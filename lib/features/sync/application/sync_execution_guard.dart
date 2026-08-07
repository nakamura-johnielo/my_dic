import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/port/session_fence.dart';
import 'package:my_dic/features/sync/application/report/sync_reason_codes.dart';

/// Guards handler-side effects against a session that changed mid-cycle.
///
/// The engine performs the same check between datasets. Handlers use this
/// guard around individual remote and local side effects so an old account
/// cannot acknowledge, apply, or checkpoint after an account switch.
class SyncExecutionGuard {
  const SyncExecutionGuard([this._sessionFence]);

  final SessionFence? _sessionFence;

  bool canContinue(SyncContext context) =>
      !context.cancellation.isCancelled &&
      (_sessionFence?.isCurrent(
            accountId: context.accountId,
            sessionEpoch: context.sessionEpoch,
          ) ??
          true);

  /// Throws inside transactional callbacks so an invalidated session causes
  /// the transaction to roll back instead of silently committing a prefix of
  /// the remote changes.
  void ensureCanContinue(SyncContext context) {
    if (!canContinue(context)) {
      throw SyncExecutionCancelled(cancellationReason(context));
    }
  }

  String cancellationReason(SyncContext context) => _sessionFence?.isCurrent(
            accountId: context.accountId,
            sessionEpoch: context.sessionEpoch,
          ) ==
          false
      ? SyncReasonCodes.sessionChanged
      : SyncReasonCodes.callerCancelled;
}

class SyncExecutionCancelled implements Exception {
  const SyncExecutionCancelled(this.reason);

  final String reason;
}
