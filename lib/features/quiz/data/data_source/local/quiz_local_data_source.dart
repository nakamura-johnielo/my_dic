import 'package:my_dic/features/quiz/data/data_source/local/quiz_json_dao.dart';
import 'package:my_dic/features/quiz/data/data_source/local/i_quiz_local_data_source.dart';

class QuizLocalDataSource implements IQuizLocalDataSource {
  final QuizJsonDao dao;
  QuizLocalDataSource({required this.dao});

  @override
  Future<Map<String, String>> getConjEnglishGuide() async {
    final raw = await dao.loadConjEnglishGuide();
    return raw.map((k, v) => MapEntry(k, v.toString()));
  }

  @override
  Future<Map<String, Map<String, String>>> getConjOfBe() async {
    final raw = await dao.loadBeConj();
    return raw.map((k, v) {
      final inner = (v as Map<String, dynamic>)
          .map((s, t) => MapEntry(s, t.toString()));
      return MapEntry(k, inner);
    });
  }
}
