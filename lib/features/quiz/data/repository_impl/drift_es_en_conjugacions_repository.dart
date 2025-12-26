import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/es_en_conjugacion_dao.dart';
import 'package:my_dic/features/quiz/domain/usecase/fetch_english_conj.dart/i_fetch_english_conj_repository.dart';

class DriftEsEnConjugacionRepository implements IEsEnConjugacionRepository{
  final EsEnConjugacionDao _esEnConjugacionDao;

  DriftEsEnConjugacionRepository(this._esEnConjugacionDao);

  @override
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
