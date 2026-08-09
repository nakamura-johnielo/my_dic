import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/sync/remote/firebase_esp_jpn_word_status_data_source.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/sync/remote/firebase_word_status_dao.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/sync/remote/i_esp_jpn_word_status_remote_data_source.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/sync/esp_jpn_word_status_sync_handler.dart';

// ===============datasource====================

final localWordStatusDataSourceProvider =
    Provider<ILocalWordStatusDataSource>((ref) {
  return DriftWordStatusDataSource(ref.read(localWordStatusDaoProvider));
});

final remoteWordStatusDataSourceProvider =
    Provider<IEspJpnWordStatusRemoteDataSource>((ref) {
  return FirebaseEspJpnWordStatusDataSource(
      ref.read(remoteWordStatusDaoProvider));
});

final remoteWordStatusDaoProvider = Provider<FirebaseWordStatusDao>((ref) {
  return FirebaseWordStatusDao(ref.read(firestoreDBProvider));
});

// ===============sync handler====================
final espJpnWordStatusSyncHandlerProvider =
    Provider<EspJpnWordStatusSyncHandler>((ref) {
  return EspJpnWordStatusSyncHandler(
    queue: ref.watch(driftSyncQueueProvider),
    executionGuard: ref.watch(syncExecutionGuardProvider),
    checkpointStore: ref.watch(driftSyncCheckpointStoreProvider),
    local: ref.read(localWordStatusDataSourceProvider),
    remote: ref.read(remoteWordStatusDataSourceProvider),
  );
});
