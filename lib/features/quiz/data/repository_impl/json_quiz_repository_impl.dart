import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/data/data_source/local/json_handler.dart';
import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_repository.dart';

class JsonQuizRepositoryImpl implements IEnglishConjSubRepository {
  final JsonHandler jsonHandler;
   JsonQuizRepositoryImpl({required this.jsonHandler});

  @override
  Future<Result<Map<String, String>>> getConjEnglishGuide() async {
    try {
      final map = await jsonHandler.getConjEnglishGuide();
      final result = map.map((k, v) => MapEntry(k, v.toString()));
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
      final map = await jsonHandler.getBeConj();
      final result = map.map((k, v) {
        final innerMap =
            (v as Map<String, dynamic>).map((s, t) => MapEntry(s, t.toString()));
        return MapEntry(k, innerMap);
      });
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