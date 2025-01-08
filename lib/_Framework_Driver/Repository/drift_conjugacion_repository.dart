import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_conjugation_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/conjugation_dao.dart';

class DriftConjugacionRepository implements IConjugacionsRepository {
  final ConjugationDao _conjugacionDao;
  DriftConjugacionRepository(this._conjugacionDao);

  @override
  Future<Conjugacions?> getConjugacionByWordId(int id) async {
    final res = await _conjugacionDao.getConjugationById(id);
    if (res == null) {
      return null; // 結果がnullの場合はnullを返す
    }

    return Conjugacions(
        wordId: res.wordId, conjugacions: convertToConjugations(res));
  }
}

const nonText = "--";

Map<MoodTense, TenseConjugacion> convertToConjugations(data) {
  return {
    MoodTense.indicativePresent: TenseConjugacion(
      yo: data.indicativePresentYo ?? nonText,
      tu: data.indicativePresentTu ?? nonText,
      el: data.indicativePresentEl ?? nonText,
      nosotros: data.indicativePresentNosotros ?? nonText,
      vosotros: data.indicativePresentVosotros ?? nonText,
      ellos: data.indicativePresentEllos ?? nonText,
    ),
    MoodTense.indicativePreterite: TenseConjugacion(
      yo: data.indicativePreteriteYo ?? nonText,
      tu: data.indicativePreteriteTu ?? nonText,
      el: data.indicativePreteriteEl ?? nonText,
      nosotros: data.indicativePreteriteNosotros ?? nonText,
      vosotros: data.indicativePreteriteVosotros ?? nonText,
      ellos: data.indicativePreteriteEllos ?? nonText,
    ),
    MoodTense.indicativeImperfect: TenseConjugacion(
      yo: data.indicativeImperfectYo ?? nonText,
      tu: data.indicativeImperfectTu ?? nonText,
      el: data.indicativeImperfectEl ?? nonText,
      nosotros: data.indicativeImperfectNosotros ?? nonText,
      vosotros: data.indicativeImperfectVosotros ?? nonText,
      ellos: data.indicativeImperfectEllos ?? nonText,
    ),
    MoodTense.indicativeFuture: TenseConjugacion(
      yo: data.indicativeFutureYo ?? nonText,
      tu: data.indicativeFutureTu ?? nonText,
      el: data.indicativeFutureEl ?? nonText,
      nosotros: data.indicativeFutureNosotros ?? nonText,
      vosotros: data.indicativeFutureVosotros ?? nonText,
      ellos: data.indicativeFutureEllos ?? nonText,
    ),
    MoodTense.indicativeConditional: TenseConjugacion(
      yo: data.indicativeConditionalYo ?? nonText,
      tu: data.indicativeConditionalTu ?? nonText,
      el: data.indicativeConditionalEl ?? nonText,
      nosotros: data.indicativeConditionalNosotros ?? nonText,
      vosotros: data.indicativeConditionalVosotros ?? nonText,
      ellos: data.indicativeConditionalEllos ?? nonText,
    ),
    MoodTense.imperative: TenseConjugacion(
      yo: nonText, // Imperative mood typically doesn't have a first person conjugation
      tu: data.imperativeTu ?? nonText,
      el: data.imperativeEl ?? nonText,
      nosotros: data.imperativeNosotros ?? nonText,
      vosotros: data.imperativeVosotros ?? nonText,
      ellos: data.imperativeEllos ?? nonText,
    ),
    MoodTense.subjunctivePresent: TenseConjugacion(
      yo: data.subjunctivePresentYo ?? nonText,
      tu: data.subjunctivePresentTu ?? nonText,
      el: data.subjunctivePresentEl ?? nonText,
      nosotros: data.subjunctivePresentNosotros ?? nonText,
      vosotros: data.subjunctivePresentVosotros ?? nonText,
      ellos: data.subjunctivePresentEllos ?? nonText,
    ),
    MoodTense.subjunctivePast: TenseConjugacion(
      yo: data.subjunctivePastYo ?? nonText,
      tu: data.subjunctivePastTu ?? nonText,
      el: data.subjunctivePastEl ?? nonText,
      nosotros: data.subjunctivePastNosotros ?? nonText,
      vosotros: data.subjunctivePastVosotros ?? nonText,
      ellos: data.subjunctivePastEllos ?? nonText,
    ),
  };
}
