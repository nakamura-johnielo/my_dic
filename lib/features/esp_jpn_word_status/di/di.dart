import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/esp_jpn/status_buttons_command.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_command_event.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/viewmodel.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/fetch_esp_jpn_status/fetch__esp_jpn_status_interactor.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/fetch_esp_jpn_status/fetch_esp_jpn_status_usecase.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/firebase_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_interactor.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/wordstatus_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/esp_jpn/word_status_state.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/watch/i_watch_esp_jpn_word_status_usecase.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/watch/watch_esp_jpn_word_status_interactor.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/sync/esp_jpn_word_status_sync_handler.dart';

//==========Usecase=====================
final fetchEspJpnWordStatusUsecaseProvider =
    Provider<FetchEspJpnWordStatusUsecase>((ref) {
  return FetchEspJpnWordStatusInteractor(
    ref.read(wordStatusRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

final watchEspJpnWordStatusUsecaseProvider =
    Provider<IWatchEspJpnWordStatusUsecase>((ref) {
  return WatchEspJpnWordStatusInteractor(
    ref.read(wordStatusRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

final updateStatusUseCaseProvider = Provider<IUpdateStatusUseCase>((ref) {
  return UpdateStatusInteractor(
    ref.read(wordStatusRepositoryProvider),
    ref.watch(currentSessionProvider),
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
  return WordStatusRepository(local, ref.read(driftOutboxWriterProvider));
});

// ===============sync handler====================
final espJpnWordStatusSyncHandlerProvider =
    Provider<EspJpnWordStatusSyncHandler>((ref) {
  return EspJpnWordStatusSyncHandler(
    queue: ref.watch(driftSyncQueueProvider),
    checkpointStore: ref.watch(driftSyncCheckpointStoreProvider),
    local: ref.read(localWordStatusDataSourceProvider),
    remote: ref.read(remoteWordStatusDataSourceProvider),
  );
});

//=====viewmodel=============

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
