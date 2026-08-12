import 'package:my_dic/features/sync/port/session_fence.dart';

/// Composition roots advance the epoch whenever Auth changes account.
class InMemorySessionFence implements ISessionFence {
  final Map<String, int> _epochs = {};

  void setCurrent(String accountId, int epoch) => _epochs[accountId] = epoch;
  void remove(String accountId) => _epochs.remove(accountId);

  /// The current epoch for [accountId], or `null` if it is not the current
  /// account. Used by foreground sync triggers to build a `SyncContext`.
  int? epochFor(String accountId) => _epochs[accountId];

  @override
  bool isCurrent({required String accountId, required int sessionEpoch}) =>
      _epochs[accountId] == sessionEpoch;
}
