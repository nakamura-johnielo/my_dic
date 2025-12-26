import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/core/domain/usecase/fetch_esp_jpn_status/fetch__esp_jpn_status_interactor.dart';
import 'package:my_dic/core/domain/usecase/fetch_esp_jpn_status/fetch_esp_jpn_status_usecase.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/fetch_conjugation_interactor.dart' ;
import 'package:my_dic/core/domain/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart' ;
import 'package:my_dic/core/domain/usecase/fetch_dictionary/fetch_dictionary_interactor.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_interactor.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_interactor.dart';
import 'package:my_dic/core/domain/usecase/sync_esp_jpn_word_status/i_sync_esp_jpn_word_status_usecase.dart';
import 'package:my_dic/core/domain/usecase/sync_esp_jpn_word_status/sync_esp_jpn_word_status_interactor.dart';


final fetchEspJpnWordStatusInteractorProvider = Provider<FetchEspJpnWordStatusUsecase>((ref) {
  return FetchEspJpnWordStatusInteractor(ref.read(wordStatusRepositoryProvider));
});


final updateStatusUseCaseProvider = Provider<IUpdateStatusUseCase>((ref) {
  return UpdateStatusInteractor(
    ref.read(wordStatusRepositoryProvider),
  );
});

// final fetchEspConjugationUseCaseProvider =
//     Provider<IFetchEspConjugationUseCase>((ref) {
//   return FetchEspConjugationInteractor(
//     ref.read(fetchConjugationPresenterProvider),
//     ref.read(conjugacionsRepositoryProvider),
//   );
// });

final fetchEspConjugationUseCaseProvider =
    Provider<IFetchEspConjugationUseCase>((ref) {
  return FetchEspConjugationInteractor(
    ref.read(conjugacionsRepositoryProvider),
  );
});

final fetchEspJpnDictionaryUseCaseProvider = Provider<IFetchEspJpnDictionaryUseCase>((ref) {
  return FetchEspJpnDictionaryInteractor(
    ref.read(esjDictionaryRepositoryProvider),
  );
});

final fetchJpnEspDictionaryUseCaseProvider =
    Provider<IFetchJpnEspDictionaryUseCase>((ref) {
  return FetchJpnEspDictionaryInteractor(
    ref.read(jpnEspDictionaryRepositoryProvider),
  );
});


final syncEspJpnWordStatusUseCaseProvider=
    Provider<ISyncEspJpnWordStatusUseCase>((ref) {
  return SyncEspJpnWordStatusInteractor(
    ref.read(syncStatusRepositoryProvider),
    ref.read(localEspJpnWordStatusRepositoryProvider),
    ref.read(remoteEspJpnWordStatusRepositoryProvider),
  );
});


// ISyncEspJpnWordStatusUseCase