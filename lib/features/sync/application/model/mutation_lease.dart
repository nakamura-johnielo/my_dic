import 'package:my_dic/features/sync/application/model/sync_mutation.dart';

class MutationLease {
  const MutationLease({
    required this.mutation,
    required this.leaseToken,
    required this.leasedLocalRevision,
    required this.leaseUntil,
  });

  final SyncMutation mutation;
  final String leaseToken;
  final int leasedLocalRevision;
  final DateTime leaseUntil;
}
