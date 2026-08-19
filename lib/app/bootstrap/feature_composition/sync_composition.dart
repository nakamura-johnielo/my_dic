import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/my_word_composition.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/app/bootstrap/feature_composition/word_status_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/user_profile_composition.dart';
import 'package:my_dic/core/composition/data_di.dart';
import 'package:my_dic/features/sync/port/composition.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

export '../sync_infrastructure_providers.dart';

/// レジストリ構成は完成したMyWord機能群を登録し、移行待ちの機能は公開コンポジション
/// ファクトリーを引き続き使用します。
final syncDatasetHandlersProvider = Provider<List<DatasetSyncHandler>>((ref) {
  return [
    ref.watch(espJpnWordStatusDatasetSyncHandlerProvider),
    ref.watch(jpnEspWordStatusDatasetSyncHandlerProvider),
    ref.watch(myWordDatasetSyncHandlerProvider),
    ref.watch(myWordStatusDatasetSyncHandlerProvider),
    ref.watch(userProfileDatasetSyncHandlerProvider),
  ];
});

/// アプリワークフローが利用する唯一のSync入口。
final syncRunnerProvider = Provider<SyncRunner>((ref) {
  final runner = createSyncRunner(
    dependencies: SyncDependencies(
      database: ref.watch(databaseProvider),
      sessionFence: ref.watch(syncSessionFenceProvider),
    ),
    handlers: ref.watch(syncDatasetHandlersProvider),
  );
  ref.onDispose(runner.dispose);
  return runner;
});
