import 'model/mutation_lease.dart';
import 'model/sync_mutation.dart';
import 'sync_dataset.dart';

abstract interface class SyncQueue {
  Future<List<MutationLease>> leasePending(
      {required String accountId,
      required SyncDataset dataset,
      required int limit,
      required DateTime now,
      required Duration leaseDuration});
  Future<bool> ack(MutationLease lease);
  Future<void> retry(MutationLease lease,
      {required String errorCode, required DateTime nextAttemptAt});
  Future<void> deadLetter(MutationLease lease, {required String errorCode});
  Future<int> releaseExpiredLeases(DateTime now);

  /// [accountId] に属する保留中の変更のうち、最も早い再試行予定時刻です。
  /// リース済みおよびデッドレターの変更は意図的に除外します。
  Future<DateTime?> earliestPendingAttemptAt({required String accountId});

  /// まだ確認されていない変更（保留中または現在リース中）の非変更読み取りです。ハンドラーは、
  /// フィールドのローカル変更がサーバーへ送信中の間に古いリモート値で上書きしないために使用します。
  Future<List<SyncMutation>> peekPending(
      {required String accountId, required SyncDataset dataset});
}
