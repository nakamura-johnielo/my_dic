import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_word_status_dataset_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_sync_remote_factory.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/jpn_esp_word_status_sync_remote_factory.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_word_status_dataset_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/sync/word_status_dataset_sync_handler.dart';
import 'package:my_dic/features/word_status/port/composition.dart';

DatasetSyncHandler createInternalEspJpnWordStatusDatasetSyncHandler(
  WordStatusSyncDependencyReaderPort read, {
  required SyncHandlerRuntime runtime,
}) =>
    WordStatusDatasetSyncHandler(
      adapter: EspJpnWordStatusDatasetAdapter(
        local: EspJpnWordStatusLocalStore(
          EspJpnWordStatusDao(
            read<DatabaseProvider>(WordStatusSyncDependency.database),
          ),
        ),
        remote: createInternalFirebaseEspJpnWordStatusRemoteStore(read),
      ),
      runtime: runtime,
    );

DatasetSyncHandler createInternalJpnEspWordStatusDatasetSyncHandler(
  WordStatusSyncDependencyReaderPort read, {
  required SyncHandlerRuntime runtime,
}) =>
    WordStatusDatasetSyncHandler(
      adapter: JpnEspWordStatusDatasetAdapter(
        local: JpnEspWordStatusLocalStore(
          JpnEspWordStatusDao(
            read<DatabaseProvider>(WordStatusSyncDependency.database),
          ),
        ),
        remote: createInternalFirebaseJpnEspWordStatusRemoteStore(read),
      ),
      runtime: runtime,
    );
