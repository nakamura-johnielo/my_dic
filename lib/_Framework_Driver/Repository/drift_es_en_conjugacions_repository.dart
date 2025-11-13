import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/es_en_conjugacion_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';

class DriftEsEnConjugacionRepository {
  final EsEnConjugacionDao _esEnConjugacionDao;

  DriftEsEnConjugacionRepository(this._esEnConjugacionDao);

  Future<Map<String, String>> getEnglishConjById(int id) async {
    final res = await _esEnConjugacionDao.getEnglishConjById(id);

    return {
      EnglishMoodTense.participlePresent.toString(): res?.presentP ?? "V-ing",
      EnglishMoodTense.participlePast.toString(): res?.pastP ?? "V-en",
      EnglishMoodTense.indicativePresent.toString(): res?.english ?? "V",
      EnglishMoodTense.indicativePresent3rd.toString(): res?.present3rd ?? "Vs",
      EnglishMoodTense.indicativePast.toString(): res?.past ?? "V-ed",
    };
  }
}
