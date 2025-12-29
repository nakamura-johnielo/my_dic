import 'package:my_dic/core/shared/utils/json.dart';

class QuizJsonDao {
  QuizJsonDao();

    Future<Map<String, dynamic>> loadConjEnglishGuide() async {
    const path = 'assets/data/es_conjugacion_en_translation.json';
    final map = await readJsonFile(path);
    return map;
  }

  Future<Map<String, dynamic>> loadBeConj() async {
     const path = 'assets/data/be_conjugacion.json';
     final map = await readJsonFile(path);
    return map;
  }
}
