import 'package:my_dic/features/sync/application/model/sync_mutation.dart';

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

  /// Number of retryable failures recorded before this lease was acquired.
  final int attemptCount;
}
