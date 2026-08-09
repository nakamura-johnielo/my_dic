import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/word_status/application/port/word_status_repository.dart';
import 'package:my_dic/features/word_status/application/port/word_status_guest_migration.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_data_source.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_dictionary_word_status_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_word_status_dataset_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_remote_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_data_source.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_remote_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_dictionary_word_status_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_word_status_dataset_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/guest_migration/drift_word_status_guest_migration.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_dataset_sync_handler.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/word_status_repository_adapter.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';

/// The WordStatus-owned local and remote adapter graph for Esp-Jpn.
final espJpnWordStatusDaoProvider = Provider<EspJpnWordStatusDao>(
    (ref) => EspJpnWordStatusDao(ref.watch(databaseProvider)));

final espJpnWordStatusLocalDataSourceProvider =
    Provider<EspJpnWordStatusLocalDataSource>((ref) =>
        EspJpnWordStatusLocalStore(ref.watch(espJpnWordStatusDaoProvider)));

final firebaseEspJpnWordStatusDaoProvider =
    Provider<FirebaseEspJpnWordStatusDao>(
        (ref) => FirebaseEspJpnWordStatusDao(ref.watch(firestoreDBProvider)));

final firebaseEspJpnWordStatusRemoteStoreProvider =
    Provider<FirebaseEspJpnWordStatusRemoteStore>((ref) =>
        FirebaseEspJpnWordStatusRemoteStore(
            ref.watch(firebaseEspJpnWordStatusDaoProvider)));

final espJpnWordStatusDatasetAdapterProvider =
    Provider<EspJpnWordStatusDatasetAdapter>(
        (ref) => EspJpnWordStatusDatasetAdapter(
              local: ref.watch(espJpnWordStatusLocalDataSourceProvider),
              remote: ref.watch(firebaseEspJpnWordStatusRemoteStoreProvider),
            ));

/// The WordStatus-owned local and remote adapter graph for Jpn-Esp.
final jpnEspWordStatusDaoProvider = Provider<JpnEspWordStatusDao>(
    (ref) => JpnEspWordStatusDao(ref.watch(databaseProvider)));

final jpnEspWordStatusLocalDataSourceProvider =
    Provider<JpnEspWordStatusLocalDataSource>((ref) =>
        JpnEspWordStatusLocalStore(ref.watch(jpnEspWordStatusDaoProvider)));

final firebaseJpnEspWordStatusDaoProvider =
    Provider<FirebaseJpnEspWordStatusDao>(
        (ref) => FirebaseJpnEspWordStatusDao(ref.watch(firestoreDBProvider)));

final firebaseJpnEspWordStatusRemoteStoreProvider =
    Provider<FirebaseJpnEspWordStatusRemoteStore>((ref) =>
        FirebaseJpnEspWordStatusRemoteStore(
            ref.watch(firebaseJpnEspWordStatusDaoProvider)));

final jpnEspWordStatusDatasetAdapterProvider =
    Provider<JpnEspWordStatusDatasetAdapter>(
        (ref) => JpnEspWordStatusDatasetAdapter(
              local: ref.watch(jpnEspWordStatusLocalDataSourceProvider),
              remote: ref.watch(firebaseJpnEspWordStatusRemoteStoreProvider),
            ));

/// Separate instances are required because a handler is bound to its adapter's
/// dataset and must never share queue/checkpoint work across directions.
final espJpnWordStatusDatasetSyncHandlerProvider =
    Provider<DatasetSyncHandler>((ref) => WordStatusDatasetSyncHandler(
          adapter: ref.watch(espJpnWordStatusDatasetAdapterProvider),
          queue: ref.watch(driftSyncQueueProvider),
          checkpointStore: ref.watch(driftSyncCheckpointStoreProvider),
          executionGuard: ref.watch(syncExecutionGuardProvider),
        ));

final jpnEspWordStatusDatasetSyncHandlerProvider =
    Provider<DatasetSyncHandler>((ref) => WordStatusDatasetSyncHandler(
          adapter: ref.watch(jpnEspWordStatusDatasetAdapterProvider),
          queue: ref.watch(driftSyncQueueProvider),
          checkpointStore: ref.watch(driftSyncCheckpointStoreProvider),
          executionGuard: ref.watch(syncExecutionGuardProvider),
        ));

/// The production registry consumes exactly one handler per WordStatus dataset.
final wordStatusDatasetSyncHandlersProvider =
    Provider<List<DatasetSyncHandler>>((ref) => [
          ref.watch(espJpnWordStatusDatasetSyncHandlerProvider),
          ref.watch(jpnEspWordStatusDatasetSyncHandlerProvider),
        ]);

/// App-level composition for the unified, catalog-keyed WordStatus graph.
final wordStatusRepositoryProvider = Provider<WordStatusRepository>((ref) {
  final outboxWriter = ref.watch(driftOutboxWriterProvider);
  return WordStatusRepositoryAdapter([
    EspJpnDictionaryWordStatusAdapter(
      ref.watch(espJpnWordStatusLocalDataSourceProvider),
      outboxWriter,
    ),
    JpnEspDictionaryWordStatusAdapter(
      ref.watch(jpnEspWordStatusLocalDataSourceProvider),
      outboxWriter,
    ),
  ]);
});

/// The guest-migration capability shares the exact local stores used by the
/// repository and dataset-sync adapters above.  App workflows consume this
/// port instead of reaching into either legacy direction feature's DI.
final wordStatusGuestMigrationProvider =
    Provider<WordStatusGuestMigration>((ref) => DriftWordStatusGuestMigration(
          espJpn: ref.watch(espJpnWordStatusLocalDataSourceProvider),
          jpnEsp: ref.watch(jpnEspWordStatusLocalDataSourceProvider),
          outboxWriter: ref.watch(driftOutboxWriterProvider),
        ));
