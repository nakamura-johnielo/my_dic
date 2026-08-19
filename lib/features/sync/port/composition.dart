import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'composition_contract.dart';
import 'dataset_contract.dart';
import '../internal/composition/sync_composition_factory.dart';

export 'composition_contract.dart';

/// Sync の組み立てに必要な、アプリケーション所有の実行時依存関係です。
final class SyncDependencies {
  const SyncDependencies({
    required this.database,
    required this.sessionFence,
  });

  final DatabaseProvider database;
  final SessionFence sessionFence;
}

/// フレームワーク状態なしで完成済みの Sync インフラストラクチャを作成します。
SyncComposition createSyncComposition({
  required SyncDependencies dependencies,
}) =>
    SyncCompositionFactory.createComposition(
      database: dependencies.database,
      sessionFence: dependencies.sessionFence,
    );

/// 登録済みデータセットハンドラー用の公開ワークフローランナーを作成します。
SyncRunner createSyncRunner({
  required SyncDependencies dependencies,
  required Iterable<DatasetSyncHandler> handlers,
}) =>
    SyncCompositionFactory.createRunner(
      database: dependencies.database,
      sessionFence: dependencies.sessionFence,
      handlers: handlers,
    );
