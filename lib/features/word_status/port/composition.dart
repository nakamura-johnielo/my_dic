import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/word_status/internal/composition/word_status_sync_composition_factory.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_dictionary_word_status_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_dictionary_word_status_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/guest_migration/drift_word_status_guest_migration.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/word_status_repository_adapter.dart';
import 'package:my_dic/features/word_status/port/guest_migration.dart';
import 'package:my_dic/features/word_status/port/repository.dart';

/// Framework-neutral dependency bridge supplied by app composition.
typedef WordStatusSyncDependencyQueryPort = T Function<T>(Object dependency);

/// Dependencies requested by the WordStatus sync factories.
enum WordStatusSyncDependency {
  database,
  firestore,
  remoteMutationExecutor,
}

/// The WordStatus graph assembled by the app composition root.
final class WordStatusPorts {
  const WordStatusPorts({
    required this.repository,
    required this.guestMigration,
  });

  final IWordStatusRepository repository;
  final IWordStatusGuestMigration guestMigration;
}

/// Creates the public WordStatus capabilities from neutral infrastructure
/// dependencies. Direction-specific stores and adapters remain internal.
WordStatusPorts createWordStatusPorts({
  required DatabaseProvider database,
  required IOutboxWriter outboxWriter,
}) {
  final espJpn = EspJpnWordStatusLocalStore(EspJpnWordStatusDao(database));
  final jpnEsp = JpnEspWordStatusLocalStore(JpnEspWordStatusDao(database));
  return WordStatusPorts(
    repository: WordStatusRepositoryAdapter([
      EspJpnDictionaryWordStatusAdapter(
        espJpn,
        outboxWriter,
      ),
      JpnEspDictionaryWordStatusAdapter(
        jpnEsp,
        outboxWriter,
      ),
    ]),
    guestMigration: DriftWordStatusGuestMigration(
      espJpn: espJpn,
      jpnEsp: jpnEsp,
      outboxWriter: outboxWriter,
    ),
  );
}

/// Creates the Esp-Jpn WordStatus handler from an app dependency reader.
IDatasetSyncHandler createEspJpnWordStatusDatasetSyncHandler(
  WordStatusSyncDependencyQueryPort read, {
  required ISyncHandlerRuntime runtime,
}) =>
    createInternalEspJpnWordStatusDatasetSyncHandler(read, runtime: runtime);

/// Creates the Jpn-Esp WordStatus handler from an app dependency reader.
IDatasetSyncHandler createJpnEspWordStatusDatasetSyncHandler(
  WordStatusSyncDependencyQueryPort read, {
  required ISyncHandlerRuntime runtime,
}) =>
    createInternalJpnEspWordStatusDatasetSyncHandler(read, runtime: runtime);
