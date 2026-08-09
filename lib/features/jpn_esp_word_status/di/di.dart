import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_local_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/jpn_esp_drift_word_status_data_source.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/sync/jpn_esp_word_status_sync_handler.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/sync/remote/firebase_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/sync/remote/firebase_jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/sync/remote/i_jpn_esp_word_status_remote_data_source.dart';

// ===============Firebase DAO====================
final firebaseJpnEspWordStatusDaoProvider =
    Provider<FirebaseJpnEspWordStatusDao>((ref) {
  return FirebaseJpnEspWordStatusDao(ref.read(firestoreDBProvider));
});

// ===============datasource====================

final jpnEspLocalWordStatusDataSourceProvider =
    Provider<ILocalJpnEspWordStatusDataSource>((ref) {
  return JpnEspDriftWordStatusDataSource(ref.read(jpnEspWordStatusDaoProvider));
});

final jpnEspRemoteWordStatusDataSourceProvider =
    Provider<IJpnEspWordStatusRemoteDataSource>((ref) {
  return FirebaseJpnEspWordStatusDataSource(
      ref.read(firebaseJpnEspWordStatusDaoProvider));
});

// ===============sync handler====================
final jpnEspWordStatusSyncHandlerProvider =
    Provider<JpnEspWordStatusSyncHandler>((ref) {
  return JpnEspWordStatusSyncHandler(
    queue: ref.watch(driftSyncQueueProvider),
    executionGuard: ref.watch(syncExecutionGuardProvider),
    checkpointStore: ref.watch(driftSyncCheckpointStoreProvider),
    local: ref.read(jpnEspLocalWordStatusDataSourceProvider),
    remote: ref.read(jpnEspRemoteWordStatusDataSourceProvider),
  );
});
