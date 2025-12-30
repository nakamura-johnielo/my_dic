import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_repository.dart';
import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_usecase.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class FetchEnglishConjSubInteractor implements IFetchEnglishConjSubUsecase {
  final IEnglishConjSubRepository repository;

  FetchEnglishConjSubInteractor({required this.repository});

  @override
  Future<Result<Map<String, String>>> getConjEnglishGuide() async {
    final result = await repository.getConjEnglishGuide();
    return result;
  }

  @override
  Future<Result<Map<String, Map<String, String>>>> getConjOfBe() async {
    final result = await repository.getConjOfBe();
    return result;
  }
}