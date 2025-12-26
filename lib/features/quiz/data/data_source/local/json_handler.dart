import 'package:my_dic/core/shared/utils/json.dart';

class JsonHandler {
  Future<Map<String, dynamic>> getConjEnglishGuide() async {
    const path = 'assets/data/es_conjugacion_en_translation.json';
    final map = await readJsonFile(path);
    return map;
  }

  Future<Map<String, dynamic>> getBeConj() async {
     const path = 'assets/data/be_conjugacion.json';
     final map = await readJsonFile(path);
    return map;
  }
}
