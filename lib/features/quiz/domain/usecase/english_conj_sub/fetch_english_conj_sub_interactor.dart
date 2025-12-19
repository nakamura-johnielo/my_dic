import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_repository.dart';
import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_usecase.dart';

class FetchEnglishConjSubInteractor implements IFetchEnglishConjSubUsecase {
  final IEnglishConjSubRepository repository;

  FetchEnglishConjSubInteractor({required this.repository});

  @override
  Future<Map<String, String>> getConjEnglishGuide() {
    return repository.getConjEnglishGuide();
  }

  @override
  Future<Map<String, Map<String, String>>> getConjOfBe() {
    return repository.getConjOfBe();
  }
}