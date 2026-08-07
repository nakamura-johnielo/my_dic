import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/fetch_conjugation_interactor.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/fetch_dictionary_interactor.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_interactor.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';

final fetchEspConjugationUseCaseProvider =
    Provider<IFetchEspConjugationUseCase>((ref) {
  return FetchEspConjugationInteractor(
    ref.read(conjugacionsRepositoryProvider),
  );
});

final fetchEspJpnDictionaryUseCaseProvider =
    Provider<IFetchEspJpnDictionaryUseCase>((ref) {
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
