import 'package:my_dic/features/sync/application/port/session_fence.dart';

/// Composition roots advance the epoch whenever Auth changes account.
class InMemorySessionFence implements SessionFence {
  final Map<String, int> _epochs = {};

  void setCurrent(String accountId, int epoch) => _epochs[accountId] = epoch;
  void remove(String accountId) => _epochs.remove(accountId);

  @override
  bool isCurrent({required String accountId, required int sessionEpoch}) =>
      _epochs[accountId] == sessionEpoch;
}
