import 'package:my_dic/features/sync/port/session_fence.dart';

/// 構成ルートは Auth によるアカウント変更のたびにエポックを進めます。
class InMemorySessionFence implements SessionFence {
  final Map<String, int> _epochs = {};

  void setCurrent(String accountId, int epoch) => _epochs[accountId] = epoch;
  void remove(String accountId) => _epochs.remove(accountId);

  /// [accountId] の現在のエポックです。現在のアカウントでない場合は `null` です。
  /// フォアグラウンド同期トリガーが `SyncContext` を構築するために使用します。
  int? epochFor(String accountId) => _epochs[accountId];

  @override
  bool isCurrent({required String accountId, required int sessionEpoch}) =>
      _epochs[accountId] == sessionEpoch;
}
