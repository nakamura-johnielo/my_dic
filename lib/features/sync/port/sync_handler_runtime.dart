import 'dataset_sync_gateway.dart';
import 'model/dataset_sync_result.dart';
import 'model/sync_context.dart';

/// 標準データセットハンドラーに提供する、Sync 所有の実行機能です。
///
/// 実装は再試行／バックオフ／分類／ガード、およびすべての永続キュー・チェックポイントフローを
/// 所有します。機能アダプターはポリシーオブジェクトを受け取りません。
abstract interface class SyncHandlerRuntime {
  Future<DatasetSyncResult> run(
    SyncContext context,
    DatasetSyncGateway adapter,
  );
}
