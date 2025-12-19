import 'package:my_dic/features/quiz/data/data_source/local/json_handler.dart';
import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_repository.dart';

class JsonQuizRepositoryImpl implements IEnglishConjSubRepository {
  final JsonHandler jsonHandler;
   JsonQuizRepositoryImpl({required this.jsonHandler});

  @override
  Future<Map<String, String>> getConjEnglishGuide() async {
    final map = await jsonHandler.getConjEnglishGuide();
    return map.map((k, v) => MapEntry(k, v.toString()));

  }

  @override
  Future<Map<String, Map<String, String>>> getConjOfBe() async {
    final map = await jsonHandler.getBeConj();
    return map.map((k, v) {
    final innerMap =
        (v as Map<String, dynamic>).map((s, t) => MapEntry(s, t.toString()));
    return MapEntry(k, innerMap);
  });
  }
}