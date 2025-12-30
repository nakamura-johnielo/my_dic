import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/conjugacion/enum_mood_tense_subject.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/participles.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/conjugation_dao.dart';

import 'i_conjugacion_local_datasource.dart';

const nonText = "--";

class ConjugacionDriftDataSource implements IConjugacionLocalDataSource {
  final ConjugationDao _conjugacionDao;
  ConjugacionDriftDataSource(this._conjugacionDao);

  @override
  Future<EspConjugacions?> getConjugacionByWordId(int id) async {
    final res = await _conjugacionDao.getConjugationById(id);
    if (res == null) return null;
    return EspConjugacions(
        wordId: res.wordId,
        conjugacions: _convertToConjugations(res),
        participles: EspParticiples(
            present: res.presentParticiple ?? nonText,
            past: res.pastParticiple ?? nonText));
  }

  @override
  Future<List<SearchResultConjugacions>> getConjugacionByWordWithPage(
      String word, int size, int currentPage) async {
    final conjugaciones = await _conjugacionDao.getConjugationByWordWithPage(
        word, size, currentPage);
    List<SearchResultConjugacions> res = [];
    if (conjugaciones == null) return res;

    res = conjugaciones.map((conj) {
      final matches = _check(conj);
      return SearchResultConjugacions(
          wordId: conj.wordId, word: conj.word, matches: matches);
    }).toList();
    return res;
  }

  @override
  Future<List<QuizSearchedItem>> getQuizConjugacionByWordWithPage(
      String word, int size, int currentPage) async {
    final conjugaciones = await _conjugacionDao
        .getConjugationInAllTableByWordWithPage(word, size, currentPage);
    List<QuizSearchedItem> res = [];
    if (conjugaciones == null) return res;

    res = conjugaciones.map((conj) {
      return QuizSearchedItem(
          wordId: conj.wordId, word: conj.word, simpleMeaning: conj.meaning ?? "");
    }).toList();
    return res;
  }

  Map<MoodTenseSubject, String> _check(EspConjugationTableData conjugacion) {
    Map<MoodTenseSubject, String> res = {};
    if (conjugacion.presentParticiple != null &&
        conjugacion.presentParticiple!.isNotEmpty) {
      res[MoodTenseSubject.present_participle] =
          conjugacion.presentParticiple ?? "";
    }
    if (conjugacion.pastParticiple != null &&
        conjugacion.pastParticiple!.isNotEmpty) {
      res[MoodTenseSubject.past_participle] = conjugacion.pastParticiple ?? "";
    }
    if (conjugacion.indicativePresentYo != null &&
        conjugacion.indicativePresentYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresent_yo] =
          conjugacion.indicativePresentYo ?? "";
    }
    if (conjugacion.indicativePresentTu != null &&
        conjugacion.indicativePresentTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresent_tu] =
          conjugacion.indicativePresentTu ?? "";
    }
    if (conjugacion.indicativePresentEl != null &&
        conjugacion.indicativePresentEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresent_el] =
          conjugacion.indicativePresentEl ?? "";
    }
    if (conjugacion.indicativePresentNosotros != null &&
        conjugacion.indicativePresentNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresent_nosotros] =
          conjugacion.indicativePresentNosotros ?? "";
    }
    if (conjugacion.indicativePresentVosotros != null &&
        conjugacion.indicativePresentVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresent_vosotros] =
          conjugacion.indicativePresentVosotros ?? "";
    }
    if (conjugacion.indicativePresentEllos != null &&
        conjugacion.indicativePresentEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresent_ellos] =
          conjugacion.indicativePresentEllos ?? "";
    }
    if (conjugacion.indicativePreteriteYo != null &&
        conjugacion.indicativePreteriteYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreterite_yo] =
          conjugacion.indicativePreteriteYo ?? "";
    }
    if (conjugacion.indicativePreteriteTu != null &&
        conjugacion.indicativePreteriteTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreterite_tu] =
          conjugacion.indicativePreteriteTu ?? "";
    }
    if (conjugacion.indicativePreteriteEl != null &&
        conjugacion.indicativePreteriteEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreterite_el] =
          conjugacion.indicativePreteriteEl ?? "";
    }
    if (conjugacion.indicativePreteriteNosotros != null &&
        conjugacion.indicativePreteriteNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreterite_nosotros] =
          conjugacion.indicativePreteriteNosotros ?? "";
    }
    if (conjugacion.indicativePreteriteVosotros != null &&
        conjugacion.indicativePreteriteVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreterite_vosotros] =
          conjugacion.indicativePreteriteVosotros ?? "";
    }
    if (conjugacion.indicativePreteriteEllos != null &&
        conjugacion.indicativePreteriteEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreterite_ellos] =
          conjugacion.indicativePreteriteEllos ?? "";
    }
    if (conjugacion.indicativeImperfectYo != null &&
        conjugacion.indicativeImperfectYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfect_yo] =
          conjugacion.indicativeImperfectYo ?? "";
    }
    if (conjugacion.indicativeImperfectTu != null &&
        conjugacion.indicativeImperfectTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfect_tu] =
          conjugacion.indicativeImperfectTu ?? "";
    }
    if (conjugacion.indicativeImperfectEl != null &&
        conjugacion.indicativeImperfectEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfect_el] =
          conjugacion.indicativeImperfectEl ?? "";
    }
    if (conjugacion.indicativeImperfectNosotros != null &&
        conjugacion.indicativeImperfectNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfect_nosotros] =
          conjugacion.indicativeImperfectNosotros ?? "";
    }
    if (conjugacion.indicativeImperfectVosotros != null &&
        conjugacion.indicativeImperfectVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfect_vosotros] =
          conjugacion.indicativeImperfectVosotros ?? "";
    }
    if (conjugacion.indicativeImperfectEllos != null &&
        conjugacion.indicativeImperfectEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfect_ellos] =
          conjugacion.indicativeImperfectEllos ?? "";
    }
    if (conjugacion.indicativeFutureYo != null &&
        conjugacion.indicativeFutureYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFuture_yo] =
          conjugacion.indicativeFutureYo ?? "";
    }
    if (conjugacion.indicativeFutureTu != null &&
        conjugacion.indicativeFutureTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFuture_tu] =
          conjugacion.indicativeFutureTu ?? "";
    }
    if (conjugacion.indicativeFutureEl != null &&
        conjugacion.indicativeFutureEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFuture_el] =
          conjugacion.indicativeFutureEl ?? "";
    }
    if (conjugacion.indicativeFutureNosotros != null &&
        conjugacion.indicativeFutureNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFuture_nosotros] =
          conjugacion.indicativeFutureNosotros ?? "";
    }
    if (conjugacion.indicativeFutureVosotros != null &&
        conjugacion.indicativeFutureVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFuture_vosotros] =
          conjugacion.indicativeFutureVosotros ?? "";
    }
    if (conjugacion.indicativeFutureEllos != null &&
        conjugacion.indicativeFutureEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFuture_ellos] =
          conjugacion.indicativeFutureEllos ?? "";
    }
    if (conjugacion.indicativeConditionalYo != null &&
        conjugacion.indicativeConditionalYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditional_yo] =
          conjugacion.indicativeConditionalYo ?? "";
    }
    if (conjugacion.indicativeConditionalTu != null &&
        conjugacion.indicativeConditionalTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditional_tu] =
          conjugacion.indicativeConditionalTu ?? "";
    }
    if (conjugacion.indicativeConditionalEl != null &&
        conjugacion.indicativeConditionalEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditional_el] =
          conjugacion.indicativeConditionalEl ?? "";
    }
    if (conjugacion.indicativeConditionalNosotros != null &&
        conjugacion.indicativeConditionalNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditional_nosotros] =
          conjugacion.indicativeConditionalNosotros ?? "";
    }
    if (conjugacion.indicativeConditionalVosotros != null &&
        conjugacion.indicativeConditionalVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditional_vosotros] =
          conjugacion.indicativeConditionalVosotros ?? "";
    }
    if (conjugacion.indicativeConditionalEllos != null &&
        conjugacion.indicativeConditionalEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditional_ellos] =
          conjugacion.indicativeConditionalEllos ?? "";
    }
    if (conjugacion.imperativeTu != null &&
        conjugacion.imperativeTu!.isNotEmpty) {
      res[MoodTenseSubject.imperative_tu] = conjugacion.imperativeTu ?? "";
    }
    if (conjugacion.imperativeEl != null &&
        conjugacion.imperativeEl!.isNotEmpty) {
      res[MoodTenseSubject.imperative_el] = conjugacion.imperativeEl ?? "";
    }
    if (conjugacion.imperativeNosotros != null &&
        conjugacion.imperativeNosotros!.isNotEmpty) {
      res[MoodTenseSubject.imperative_nosotros] =
          conjugacion.imperativeNosotros ?? "";
    }
    if (conjugacion.imperativeVosotros != null &&
        conjugacion.imperativeVosotros!.isNotEmpty) {
      res[MoodTenseSubject.imperative_vosotros] =
          conjugacion.imperativeVosotros ?? "";
    }
    if (conjugacion.imperativeEllos != null &&
      conjugacion.imperativeEllos!.isNotEmpty) {
      res[MoodTenseSubject.imperative_ellos] =
        conjugacion.imperativeEllos ?? "";
    }
    if (conjugacion.subjunctivePresentYo != null &&
        conjugacion.subjunctivePresentYo!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresent_yo] =
          conjugacion.subjunctivePresentYo ?? "";
    }
    if (conjugacion.subjunctivePresentTu != null &&
        conjugacion.subjunctivePresentTu!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresent_tu] =
          conjugacion.subjunctivePresentTu ?? "";
    }
    if (conjugacion.subjunctivePresentEl != null &&
        conjugacion.subjunctivePresentEl!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresent_el] =
          conjugacion.subjunctivePresentEl ?? "";
    }
    if (conjugacion.subjunctivePresentNosotros != null &&
        conjugacion.subjunctivePresentNosotros!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresent_nosotros] =
          conjugacion.subjunctivePresentNosotros ?? "";
    }
    if (conjugacion.subjunctivePresentVosotros != null &&
        conjugacion.subjunctivePresentVosotros!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresent_vosotros] =
          conjugacion.subjunctivePresentVosotros ?? "";
    }
    if (conjugacion.subjunctivePresentEllos != null &&
        conjugacion.subjunctivePresentEllos!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresent_ellos] =
          conjugacion.subjunctivePresentEllos ?? "";
    }
    if (conjugacion.subjunctivePastYo != null &&
        conjugacion.subjunctivePastYo!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePast_yo] =
          conjugacion.subjunctivePastYo ?? "";
    }
    if (conjugacion.subjunctivePastTu != null &&
        conjugacion.subjunctivePastTu!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePast_tu] =
          conjugacion.subjunctivePastTu ?? "";
    }
    if (conjugacion.subjunctivePastEl != null &&
        conjugacion.subjunctivePastEl!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePast_el] =
          conjugacion.subjunctivePastEl ?? "";
    }
    if (conjugacion.subjunctivePastNosotros != null &&
        conjugacion.subjunctivePastNosotros!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePast_nosotros] =
          conjugacion.subjunctivePastNosotros ?? "";
    }
    if (conjugacion.subjunctivePastVosotros != null &&
        conjugacion.subjunctivePastVosotros!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePast_vosotros] =
          conjugacion.subjunctivePastVosotros ?? "";
    }
    if (conjugacion.subjunctivePastEllos != null &&
        conjugacion.subjunctivePastEllos!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePast_ellos] =
          conjugacion.subjunctivePastEllos ?? "";
    }
    return res;
  }

  Map<MoodTense, TenseConjugacion> _convertToConjugations(data) {
    return {
      MoodTense.participlePresent: TenseConjugacion(
        yo: data.presentParticiple ?? nonText,
        tu: nonText,
        el: nonText,
        nosotros: nonText,
        vosotros: nonText,
        ellos: nonText,
      ),
      MoodTense.participlePast: TenseConjugacion(
        yo: data.pastParticiple ?? nonText,
        tu: nonText,
        el: nonText,
        nosotros: nonText,
        vosotros: nonText,
        ellos: nonText,
      ),
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
        yo: nonText,
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
}
