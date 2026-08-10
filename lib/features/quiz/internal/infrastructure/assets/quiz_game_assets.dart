import 'package:my_dic/core/shared/utils/json.dart';

/// Reads the two bundled English prompt assets used by the legacy game.
final class QuizGameAssets {
  Future<Map<String, String>> loadEnglishGuide() async {
    final raw =
        await readJsonFile('assets/data/es_conjugacion_en_translation.json');
    return raw.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<Map<String, Map<String, String>>> loadBeConjugation() async {
    final raw = await readJsonFile('assets/data/be_conjugacion.json');
    return raw.map((key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>)
              .map((subject, form) => MapEntry(subject, form.toString())),
        ));
  }
}
