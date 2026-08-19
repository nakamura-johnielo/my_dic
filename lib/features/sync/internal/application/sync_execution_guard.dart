import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/session_fence.dart';
import 'package:my_dic/features/sync/port/sync_reason_codes.dart';

/// サイクル途中で変更されたセッションに対して、ハンドラー側の副作用を防ぎます。
///
/// エンジンはデータセット間でも同じ検査を実行します。ハンドラーは個々のリモートおよびローカル
/// 副作用をこのガードで囲み、アカウント切替後に古いアカウントが確認、適用、チェックポイントを
/// 実行できないようにします。
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

  /// トランザクションコールバック内で例外を送出し、無効化されたセッションがリモート変更の一部を
  /// 黙ってコミットするのではなく、トランザクションをロールバックさせます。
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
