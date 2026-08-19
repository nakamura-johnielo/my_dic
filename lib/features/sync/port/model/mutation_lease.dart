import 'sync_mutation.dart';

class MutationLease {
  const MutationLease({
    required this.mutation,
    required this.leaseToken,
    required this.leasedLocalRevision,
    required this.leaseUntil,
    required this.attemptCount,
  });

  final SyncMutation mutation;
  final String leaseToken;
  final int leasedLocalRevision;
  final DateTime leaseUntil;

  /// このリースを取得する前に記録された再試行可能な失敗の回数です。
  final int attemptCount;
}
