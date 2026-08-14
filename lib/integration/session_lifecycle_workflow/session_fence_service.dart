import 'package:my_dic/features/sync/port/sync.dart';

/// App-owned projection of epochs emitted by [SessionEpochCoordinator].
///
/// It never creates epochs; it only records the coordinator's current scope
/// so Sync can reject stale work.
final class SessionFenceService implements SessionFence {
  final Map<String, int> _epochs = {};

  void activate(String accountId, int epoch) => _epochs[accountId] = epoch;
  void deactivate(String accountId) => _epochs.remove(accountId);

  @override
  bool isCurrent({required String accountId, required int sessionEpoch}) =>
      _epochs[accountId] == sessionEpoch;
}
