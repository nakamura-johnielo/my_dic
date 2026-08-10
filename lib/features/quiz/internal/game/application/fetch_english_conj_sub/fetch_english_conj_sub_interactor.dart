import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/internal/game/application/fetch_english_conj_sub/i_fetch_english_conj_sub_usecase.dart';
import 'package:my_dic/features/quiz/internal/game/domain/repository/i_english_conj_sub_repository.dart';

class FetchEnglishConjSubInteractor implements IFetchEnglishConjSubUsecase {
  final IEnglishConjSubRepository _repository;

  FetchEnglishConjSubInteractor({required IEnglishConjSubRepository repository})
      : _repository = repository;

  @override
  Future<Result<Map<String, String>>> getConjEnglishGuide() =>
      _repository.getConjEnglishGuide();

  @override
  Future<Result<Map<String, Map<String, String>>>> getConjOfBe() =>
      _repository.getConjOfBe();
}
