import 'package:my_dic/features/sync/application/cancellation_token.dart';

class SyncContext {
  const SyncContext({
    required this.accountId,
    required this.sessionEpoch,
    required this.reason,
    required this.cancellation,
  }) : assert(accountId != '');

  final String accountId;
  final int sessionEpoch;
  final String reason;
  final CancellationToken cancellation;
}
