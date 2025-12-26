import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_repository.dart';
import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_usecase.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class FetchEnglishConjSubInteractor implements IFetchEnglishConjSubUsecase {
  final IEnglishConjSubRepository repository;

  FetchEnglishConjSubInteractor({required this.repository});

  @override
  Future<Result<Map<String, String>>> getConjEnglishGuide() async {
    try {
      final result = await repository.getConjEnglishGuide();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.failure(CacheError(
        message: '英語活用ガイドの読み込みに失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<Map<String, Map<String, String>>>> getConjOfBe() async {
    try {
      final result = await repository.getConjOfBe();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.failure(CacheError(
        message: 'Be動詞活用形の読み込みに失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}