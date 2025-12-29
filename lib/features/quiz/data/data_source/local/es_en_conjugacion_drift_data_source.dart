import 'package:my_dic/core/infrastructure/database/drift/daos/es_en_conjugacion_dao.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/features/quiz/data/data_source/local/i_es_en_conjugacion_local_data_source.dart';

class EsEnConjugacionDriftDataSource implements IEsEnConjugacionLocalDataSource {
  final EsEnConjugacionDao _dao;
  EsEnConjugacionDriftDataSource(this._dao);

  @override
  Future<Map<String, String>> getEnglishConjById(int id) async {
    final res = await _dao.getEnglishConjById(id);
    return {
      EnglishMoodTense.participlePresent.toString(): res?.presentP ?? "V-ing",
      EnglishMoodTense.participlePast.toString(): res?.pastP ?? "V-en",
      EnglishMoodTense.indicativePresent.toString(): res?.english ?? "V",
      EnglishMoodTense.indicativePresent3rd.toString(): res?.present3rd ?? "Vs",
      EnglishMoodTense.indicativePast.toString(): res?.past ?? "V-ed",
    };
  }
}
