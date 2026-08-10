import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/internal/game/data/data_source/local/i_quiz_local_data_source.dart';
import 'package:my_dic/features/quiz/internal/game/domain/repository/i_english_conj_sub_repository.dart';

class QuizRepositoryImpl implements IEnglishConjSubRepository {
  final IQuizLocalDataSource localDataSource;

  QuizRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<Map<String, String>>> getConjEnglishGuide() async {
    try {
      final result = await localDataSource.getConjEnglishGuide();
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
      final result = await localDataSource.getConjOfBe();
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
