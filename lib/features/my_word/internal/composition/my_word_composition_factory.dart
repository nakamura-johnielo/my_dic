import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/application/my_word_application_service.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dao/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dao/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/query/drift_my_word_item_query_service.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/repository/drift_my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/repository/drift_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dataSource/drift_my_word_status_store.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dataSource/drift_my_word_store.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/guest_migration/my_word_guest_migration_service.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/my_word_sync_remote_factory.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/my_word_status_sync_remote_factory.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/sync/my_word_dataset_sync_service.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/sync/my_word_status_dataset_sync_service.dart';
import 'package:my_dic/features/my_word/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

/// 完成済み MyWord 機能すべての、正規の所有者限定アセンブリ。
MyWordPorts createInternalMyWordPorts({
  required DatabaseProvider database,
  required OutboxWriter outboxWriter,
}) {
  final wordLocal = DriftMyWordDataSource(MyWordDao(database));
  final statusLocal = DriftMyWordStatusDataSource(MyWordStatusDao(database));
  final wordRepository = DriftMyWordRepository(wordLocal, outboxWriter);
  final statusRepository =
      DriftMyWordStatusRepository(statusLocal, outboxWriter);
  final application = MyWordApplicationService(
    wordRepository: wordRepository,
    statusRepository: statusRepository,
    itemQuery: DriftMyWordItemQueryRepository(MyWordDao(database)),
  );
  return MyWordPorts(
    reader: application,
    commands: application,
    statusCommands: application,
    guestMigration: MyWordGuestMigrationService(
      wordLocal,
      statusLocal,
      outboxWriter,
    ),
  );
}

DatasetSyncHandler createInternalMyWordDatasetSyncHandler({
  required DatabaseProvider database,
  required FirebaseAccountNestedUpdatedDocumentGateway remoteDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
  required SyncHandlerRuntime runtime,
}) =>
    DatasetSyncService(
      adapter: MyWordDatasetSyncService(
        local: DriftMyWordDataSource(MyWordDao(database)),
        remote: createFirebaseMyWordRemoteGateway(
          remoteDocuments: remoteDocuments,
          remoteMutationExecutor: remoteMutationExecutor,
        ),
      ),
      runtime: runtime,
    );

DatasetSyncHandler createInternalMyWordStatusDatasetSyncHandler({
  required DatabaseProvider database,
  required FirebaseAccountNestedUpdatedDocumentGateway remoteDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
  required SyncHandlerRuntime runtime,
}) =>
    DatasetSyncService(
      adapter: MyWordStatusDatasetSyncService(
        local: DriftMyWordStatusDataSource(MyWordStatusDao(database)),
        remote: createFirebaseMyWordStatusRemoteGateway(
          remoteDocuments: remoteDocuments,
          remoteMutationExecutor: remoteMutationExecutor,
        ),
      ),
      runtime: runtime,
    );
