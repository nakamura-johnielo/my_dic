



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/status_buttons_view_model.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/fetch_esp_jpn_status/fetch__esp_jpn_status_interactor.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/fetch_esp_jpn_status/fetch_esp_jpn_status_usecase.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/firebase_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/sync_esp_jpn_word_status/i_sync_esp_jpn_word_status_usecase.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/sync_esp_jpn_word_status/sync_esp_jpn_word_status_interactor%20copy.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_interactor.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/wordstatus_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/services/remote_word_status_sync_service.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_state.dart';
import 'package:my_dic/features/auth/di/service.dart';


//==========Usecase=====================
//TODO 消す
final syncEspJpnWordStatusUseCaseProvider=
    Provider<ISyncEspJpnWordStatusUseCase>((ref) {
  return SyncEspJpnWordStatusInteractor(
    ref.read(syncStatusRepositoryProvider),
    ref.read(wordStatusRepositoryProvider),
  );
});


final fetchEspJpnWordStatusUsecaseProvider = Provider<FetchEspJpnWordStatusUsecase>((ref) {
  return FetchEspJpnWordStatusInteractor(ref.read(wordStatusRepositoryProvider));
});


final updateStatusUseCaseProvider = Provider<IUpdateStatusUseCase>((ref) {
  return UpdateStatusInteractor(
    ref.read(wordStatusRepositoryProvider),
  );
});



// ===============datasource====================

final localWordStatusDataSourceProvider =
    Provider<ILocalWordStatusDataSource>((ref) {
  return DriftWordStatusDataSource(ref.read(localWordStatusDaoProvider));
});

final remoteWordStatusDataSourceProvider =
    Provider<IRemoteWordStatusDataSource>((ref) {
  return FirebaseWordStatusDataSource(ref.read(remoteWordStatusDaoProvider));
});


// ===============repository====================
final wordStatusRepositoryProvider = Provider<IWordStatusRepository>((ref) {
  final local = ref.read(localWordStatusDataSourceProvider );
  final remote = ref.read(remoteWordStatusDataSourceProvider);
  // final localDataSource = ref.watch(localWordStatusDaoProvider);
  // return WordStatusRepository(dataSource, localDataSource);
  return WordStatusRepository(remote, local);
});


//=====viewmodel=============

final espJpnWordStatusViewModelProvider = StateNotifierProvider.family
    .autoDispose<EspJpnWordStatusViewModel, WordStatusState, int>(
  (ref, wordId) {
    final fetchUsecase = ref.watch(fetchEspJpnWordStatusUsecaseProvider);
    final updateUsecase = ref.watch(updateStatusUseCaseProvider);
    
    return EspJpnWordStatusViewModel(
      wordId,
      fetchUsecase,
      updateUsecase,
    );
  },
);







//======service=============


final espJpnWordStatusSyncServiceProvider =
    Provider<EspJpnWordStatusSyncService>((ref) {
  final syncEspJpnWordStatusUseCase =
      ref.read(syncEspJpnWordStatusUseCaseProvider);
  return EspJpnWordStatusSyncService(syncEspJpnWordStatusUseCase);
});



//userIdで
final espJpnWordStatusSyncProvider = Provider.autoDispose.family<void, String>((ref, userId) {
  if (userId.isEmpty) {
    return;
  }

  final service = ref.watch(espJpnWordStatusSyncServiceProvider);
  final sub = service.startSyncWithRemote(userId);

  ref.onDispose(() {
    sub.cancel();
  });
});


// ラッパープロバイダーで自動化
final autoEspJpnWordStatusSyncProvider = Provider.autoDispose<void>((ref) {
  final userId = ref.watch(authStoreNotifierProvider.select((a)=>a?.accountId));
  
  if (userId == null || userId.isEmpty|| userId != "logout" || userId != "anonymous") {
    return;
  }
  
  // familyプロバイダーを呼び出し
  ref.watch(espJpnWordStatusSyncProvider(userId));
});