import 'package:my_dic/features/sync/port/sync.dart';

/// [SessionEpochCoordinator] が発行するエポックの、アプリ所有の投影。
///
/// エポックを作成することはなく、コーディネーターの現在のスコープを記録するだけです。
/// これによりSyncは古い処理を拒否できます。
final class SessionFenceService implements SessionFence {
  final Map<String, int> _epochs = {};

  void activate(String accountId, int epoch) => _epochs[accountId] = epoch;
  void deactivate(String accountId) => _epochs.remove(accountId);

  @override
  bool isCurrent({required String accountId, required int sessionEpoch}) =>
      _epochs[accountId] == sessionEpoch;
}
