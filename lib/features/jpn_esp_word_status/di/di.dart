import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/infrastructure/database/firebase/daos/jpn_esp/firebase_jpn_esp_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_local_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_remote_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/jpn_esp_drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/jpn_esp_firebase_word_status_data_source.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/jpn_esp/jpn_esp_status_buttons_command.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/jpn_esp/jpn_esp_viewmodel.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/jpn_esp/jpn_esp_word_status_state.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_command_event.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/i_update_jpn_esp_status_use_case.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_interactor.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/watch/i_watch_jpn_esp_word_status_usecase.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/watch/watch_jpn_esp_word_status_interactor.dart';

//==========Usecase=====================

final watchJpnEspWordStatusUsecaseProvider =
    Provider<IWatchJpnEspWordStatusUsecase>((ref) {
  return WatchJpnEspWordStatusInteractor(
      ref.read(jpnEspWordStatusRepositoryProvider));
});

final updateJpnEspStatusUseCaseProvider =
    Provider<IUpdateJpnEspStatusUseCase>((ref) {
  return UpdateJpnEspStatusInteractor(
    ref.read(jpnEspWordStatusRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

// ===============Firebase DAO====================
final firebaseJpnEspWordStatusDaoProvider =
    Provider<FirebaseJpnEspWordStatusDao>((ref) {
  return FirebaseJpnEspWordStatusDao(FirebaseFirestore.instance);
});

// ===============datasource====================

final jpnEspLocalWordStatusDataSourceProvider =
    Provider<ILocalJpnEspWordStatusDataSource>((ref) {
  return JpnEspDriftWordStatusDataSource(ref.read(jpnEspWordStatusDaoProvider));
});

final jpnEspRemoteWordStatusDataSourceProvider =
    Provider<IRemoteJpnEspWordStatusDataSource>((ref) {
  return JpnEspFirebaseWordStatusDataSource(
      ref.read(firebaseJpnEspWordStatusDaoProvider));
});

// ===============repository====================
final jpnEspWordStatusRepositoryProvider =
    Provider<IJpnEspWordStatusRepository>((ref) {
  final local = ref.read(jpnEspLocalWordStatusDataSourceProvider);
  final remote = ref.read(jpnEspRemoteWordStatusDataSourceProvider);
  return JpnEspWordStatusRepository(
      remote, local, ref.read(driftOutboxWriterProvider));
});

//=====viewmodel=============

final jpnEspWordStatusCommandProvider = StateNotifierProvider.family
    .autoDispose<JpnEspWordStatusCommand, WordStatusCommandEvent?, int>(
  (ref, wordId) {
    final updateUsecase = ref.read(updateJpnEspStatusUseCaseProvider);
    return JpnEspWordStatusCommand(
      wordId,
      updateUsecase,
    );
  },
);

//===========streamer===================
final _jpnEspWordStatusStreamProvider =
    StreamProvider.autoDispose.family<JpnEspWordStatus, int>((ref, int wordId) {
  final usecase = ref.watch(watchJpnEspWordStatusUsecaseProvider);
  return usecase.execute(wordId);
});

//~~~~~~~~UI~~~~~~~~~~~~~~~~
final jpnEspWordStatusUiStateProvider =
    Provider.autoDispose.family<JpnEspWordStatusState, int>((ref, int wordId) {
  final statusAsync = ref.watch(_jpnEspWordStatusStreamProvider(wordId));

  return JpnEspWordStatusState.fromAsync(statusAsync);
});

//~~~~~~~~ViewModel~~~~~~~~~~~~~~~~
final jpnEspWordStatusViewModelProvider =
    Provider.autoDispose.family<JpnEspWordStatusViewModel, int>((ref, wordId) {
  final uiState = ref.watch(jpnEspWordStatusUiStateProvider(wordId));
  final command = ref.read(jpnEspWordStatusCommandProvider(wordId).notifier);

  return JpnEspWordStatusViewModel(uiState, command);
});
