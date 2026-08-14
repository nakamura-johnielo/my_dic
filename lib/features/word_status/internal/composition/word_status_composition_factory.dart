import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/internal/application/word_status_application_service.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_dictionary_word_status_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_word_status_dataset_sync_service.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_sync_remote_factory.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/guest_migration/drift_word_status_guest_migration.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/jpn_esp_word_status_sync_remote_factory.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_dictionary_word_status_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_word_status_dataset_sync_service.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_dataset_sync_handler.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/composite_word_status_repository.dart';
import 'package:my_dic/features/word_status/port/composition_contract.dart';

WordStatusPorts createInternalWordStatusPorts({
  required DatabaseProvider database,
  required OutboxWriter outboxWriter,
  required WordStatusClock clock,
}) {
  final espJpn = EspJpnWordStatusLocalStore(EspJpnWordStatusDao(database));
  final jpnEsp = JpnEspWordStatusLocalStore(JpnEspWordStatusDao(database));
  final repository = CompositeWordStatusRepository([
    EspJpnDictionaryWordStatusStore(espJpn, outboxWriter),
    JpnEspDictionaryWordStatusStore(jpnEsp, outboxWriter),
  ]);
  final application = WordStatusApplicationService(repository, clock: clock);
  return WordStatusPorts(
    reader: application,
    watcher: application,
    batchReader: application,
    commands: application,
    guestMigration: DriftWordStatusGuestMigration(
      espJpn: espJpn,
      jpnEsp: jpnEsp,
      outboxWriter: outboxWriter,
    ),
  );
}

DatasetSyncHandler createInternalEspJpnWordStatusDatasetSyncHandler({
  required DatabaseProvider database,
  required FirebaseAccountNestedDocumentGateway remoteDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
  required SyncHandlerRuntime runtime,
}) =>
    WordStatusDatasetSyncHandler(
      adapter: EspJpnWordStatusDatasetSyncService(
        local: EspJpnWordStatusLocalStore(EspJpnWordStatusDao(database)),
        remote: createInternalFirebaseEspJpnWordStatusRemoteStore(
          remoteDocuments: remoteDocuments,
          remoteMutationExecutor: remoteMutationExecutor,
        ),
      ),
      runtime: runtime,
    );

DatasetSyncHandler createInternalJpnEspWordStatusDatasetSyncHandler({
  required DatabaseProvider database,
  required FirebaseAccountNestedDocumentGateway remoteDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
  required SyncHandlerRuntime runtime,
}) =>
    WordStatusDatasetSyncHandler(
      adapter: JpnEspWordStatusDatasetSyncService(
        local: JpnEspWordStatusLocalStore(JpnEspWordStatusDao(database)),
        remote: createInternalFirebaseJpnEspWordStatusRemoteStore(
          remoteDocuments: remoteDocuments,
          remoteMutationExecutor: remoteMutationExecutor,
        ),
      ),
      runtime: runtime,
    );
