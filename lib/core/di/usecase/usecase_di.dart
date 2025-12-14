import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/fetch_conjugation_interactor.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/fetch_dictionary_interactor.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_interactor.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_interactor.dart';

final updateStatusUseCaseProvider = Provider<IUpdateStatusUseCase>((ref) {
  return UpdateStatusInteractor(
    ref.read(updateStatusPresenterProvider),
    ref.read(esjWordRepositoryProvider),
  );
});

final fetchConjugationUseCaseProvider =
    Provider<IFetchConjugationUseCase>((ref) {
  return FetchConjugationInteractor(
    ref.read(fetchConjugationPresenterProvider),
    ref.read(conjugacionsRepositoryProvider),
  );
});

final fetchDictionaryUseCaseProvider = Provider<IFetchDictionaryUseCase>((ref) {
  return FetchDictionaryInteractor(
    ref.read(fetchDictionaryPresenterProvider),
    ref.read(esjDictionaryRepositoryProvider),
  );
});

final fetchJpnEspDictionaryUseCaseProvider =
    Provider<IFetchJpnEspDictionaryUseCase>((ref) {
  return FetchJpnEspDictionaryInteractor(
    ref.read(fetchJpnEspDictionaryPresenterProvider),
    ref.read(jpnEspDictionaryRepositoryProvider),
  );
});
