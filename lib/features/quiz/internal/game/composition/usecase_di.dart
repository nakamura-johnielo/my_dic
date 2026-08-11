import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/internal/game/composition/data_di.dart';
import 'package:my_dic/features/quiz/internal/game/application/usecase/fetch_english_conj_sub_interactor.dart';
import 'package:my_dic/features/quiz/internal/game/application/usecase/i_fetch_english_conj_sub_usecase.dart';
import 'package:my_dic/features/quiz/internal/game/application/usecase/fetch_english_conj_interactor.dart';
import 'package:my_dic/features/quiz/internal/game/application/usecase/i_fetch_english_conj_usecase.dart';

final fetchEnglishConjUseCaseProvider =
    Provider<IFetchEnglishConjUseCase>((ref) {
  final repository = ref.read(esEnConjugacionRepositoryProvider);
  return FetchEnglishConjInteractor(repository);
});

final fetchEnglishConjSubUsecaseProvider =
    Provider<IFetchEnglishConjSubUsecase>((ref) {
  final repository = ref.read(fetchEnglishConjSubRepositoryProvider);
  return FetchEnglishConjSubInteractor(repository: repository);
});
