import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_repository.dart';
import 'package:my_dic/core/domain/usecase/i_sync_usecase.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/status_buttons_command.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_command_event.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/sync_esp_jpn_wordstatus_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/fetch_esp_jpn_status/fetch__esp_jpn_status_interactor.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/fetch_esp_jpn_status/fetch_esp_jpn_status_usecase.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/firebase_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/sync_esp_jpn_word_status/i_sync_esp_jpn_word_status_usecase.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/sync_esp_jpn_word_status/sync_esp_jpn_word_status_interactor.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_interactor.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/wordstatus_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_state.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/auth/di/data_di.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/watch/i_watch_esp_jpn_word_status_usecase.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/watch/watch_esp_jpn_word_status_interactor.dart';
import 'package:my_dic/features/user/di/service.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/viewmodel.dart';

//==========Usecase=====================
final syncEspJpnWordStatusUseCaseProvider = Provider<ISyncUseCase>((ref) {
  return SyncEspJpnWordStatusInteractor(
    ref.read(syncStatusRepositoryProvider),
    ref.read(wordStatusRepositoryProvider),
    ref.read(firebaseAuthRepositoryProvider),
  );
});

final fetchEspJpnWordStatusUsecaseProvider =
    Provider<FetchEspJpnWordStatusUsecase>((ref) {
  return FetchEspJpnWordStatusInteractor(
      ref.read(wordStatusRepositoryProvider));
});

final watchEspJpnWordStatusUsecaseProvider =
    Provider<IWatchEspJpnWordStatusUsecase>((ref) {
  return WatchEspJpnWordStatusInteractor(
      ref.read(wordStatusRepositoryProvider));
});

final updateStatusUseCaseProvider = Provider<IUpdateStatusUseCase>((ref) {
  return UpdateStatusInteractor(
    ref.read(wordStatusRepositoryProvider),
    ref.read(firebaseAuthRepositoryProvider),
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
  final local = ref.read(localWordStatusDataSourceProvider);
  final remote = ref.read(remoteWordStatusDataSourceProvider);
  // final localDataSource = ref.watch(localWordStatusDaoProvider);
  // return WordStatusRepository(dataSource, localDataSource);
  return WordStatusRepository(remote, local);
});

//イランかも
// final syncEspJpnWordStatusRepositoryProvider =
//     Provider<ISyncRepository>((ref) {
//   final local = ref.read(localWordStatusDataSourceProvider);
//   final remote = ref.read(remoteWordStatusDataSourceProvider);
//   final syncStatusRepo = ref.read(syncStatusRepositoryProvider);
//   return SyncEspJpnWordStatusRepository(remote, local, syncStatusRepo);
// });

//=====viewmodel=============

// final espJpnWordStatusViewModelProvider = StateNotifierProvider.family
//     .autoDispose<EspJpnWordStatusViewModel, WordStatusState, int>(
//   (ref, wordId) {
//     final fetchUsecase = ref.watch(fetchEspJpnWordStatusUsecaseProvider);
//     final updateUsecase = ref.watch(updateStatusUseCaseProvider);

//     return EspJpnWordStatusViewModel(
//       wordId,
//       fetchUsecase,
//       updateUsecase,
//     );
//   },
// );

final espJpnWordStatusCommandProvider = StateNotifierProvider.family
    .autoDispose<EspJpnWordStatusCommand, WordStatusCommandEvent?, int>(
  (ref, wordId) {
    final updateUsecase = ref.read(updateStatusUseCaseProvider);
    return EspJpnWordStatusCommand(
      wordId,
      updateUsecase,
    );
  },
);

//===========streamer===================
final _espJpnWordStatusStreamProvider =
    StreamProvider.autoDispose.family<WordStatus, int>((ref, int wordId) {
  final usecase = ref.watch(watchEspJpnWordStatusUsecaseProvider);
  return usecase.execute(wordId);
});

//~~~~~~~~UI~~~~~~~~~~~~~~~~
final espJpnWordStatusUiStateProvider =
    Provider.autoDispose.family<WordStatusState, int>((ref, int wordId) {
  final statusAsync = ref.watch(_espJpnWordStatusStreamProvider(wordId));

  return WordStatusState.fromAsync(statusAsync);
});

//~~~~~~~~ViewModel~~~~~~~~~~~~~~~~
final espJpnWordStatusViewModelProvider =
    Provider.autoDispose.family<EspJpnWordStatusViewModel, int>((ref, wordId) {
  final uiState = ref.watch(espJpnWordStatusUiStateProvider(wordId));
  final command = ref.read(espJpnWordStatusCommandProvider(wordId).notifier);

  return EspJpnWordStatusViewModel(uiState, command);
});
