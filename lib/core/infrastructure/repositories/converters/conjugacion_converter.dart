import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/conjugacion/enum_mood_tense_subject.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/participles.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart';

const nonText = "--";

class ConjugacionConverter {
  static EspConjugacions? toEntity(EspConjugationTableData? data) {
    if (data == null) return null;
    return EspConjugacions(
      wordId: data.wordId,
      conjugacions: _convertToConjugations(data),
      participles: EspParticiples(
        present: data.presentParticiple ?? nonText,
        past: data.pastParticiple ?? nonText,
      ),
    );
  }

  /// Convert EspConjugationTableData to SearchResultConjugacions for search results
  static SearchResultConjugacions toSearchResult(EspConjugationTableData data) {
    final matches = _check(data);
    return SearchResultConjugacions(
      wordId: data.wordId,
      word: data.word,
      matches: matches,
    );
  }

  /// Convert EspConjugationTableData to ConjugacionSearchResultItem for quiz
  static ConjugacionSearchResultItem toQuizItem(EspConjugationTableData data) {
    return ConjugacionSearchResultItem(
      wordId: data.wordId,
      word: data.word,
      simpleMeaning: data.meaning ?? "",
    );
  }

  /// Check which conjugation fields are present and not empty
  static Map<MoodTenseSubject, String> _check(
      EspConjugationTableData conjugacion) {
    Map<MoodTenseSubject, String> res = {};

    if (conjugacion.presentParticiple != null &&
        conjugacion.presentParticiple!.isNotEmpty) {
      res[MoodTenseSubject.presentParticiple] = conjugacion.presentParticiple!;
    }
    if (conjugacion.pastParticiple != null &&
        conjugacion.pastParticiple!.isNotEmpty) {
      res[MoodTenseSubject.pastParticiple] = conjugacion.pastParticiple!;
    }
    if (conjugacion.indicativePresentYo != null &&
        conjugacion.indicativePresentYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresentYo] =
          conjugacion.indicativePresentYo!;
    }
    if (conjugacion.indicativePresentTu != null &&
        conjugacion.indicativePresentTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresentTu] =
          conjugacion.indicativePresentTu!;
    }
    if (conjugacion.indicativePresentEl != null &&
        conjugacion.indicativePresentEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresentEl] =
          conjugacion.indicativePresentEl!;
    }
    if (conjugacion.indicativePresentNosotros != null &&
        conjugacion.indicativePresentNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresentNosotros] =
          conjugacion.indicativePresentNosotros!;
    }
    if (conjugacion.indicativePresentVosotros != null &&
        conjugacion.indicativePresentVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresentVosotros] =
          conjugacion.indicativePresentVosotros!;
    }
    if (conjugacion.indicativePresentEllos != null &&
        conjugacion.indicativePresentEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativePresentEllos] =
          conjugacion.indicativePresentEllos!;
    }
    if (conjugacion.indicativePreteriteYo != null &&
        conjugacion.indicativePreteriteYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreteriteYo] =
          conjugacion.indicativePreteriteYo!;
    }
    if (conjugacion.indicativePreteriteTu != null &&
        conjugacion.indicativePreteriteTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreteriteTu] =
          conjugacion.indicativePreteriteTu!;
    }
    if (conjugacion.indicativePreteriteEl != null &&
        conjugacion.indicativePreteriteEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreteriteEl] =
          conjugacion.indicativePreteriteEl!;
    }
    if (conjugacion.indicativePreteriteNosotros != null &&
        conjugacion.indicativePreteriteNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreteriteNosotros] =
          conjugacion.indicativePreteriteNosotros!;
    }
    if (conjugacion.indicativePreteriteVosotros != null &&
        conjugacion.indicativePreteriteVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreteriteVosotros] =
          conjugacion.indicativePreteriteVosotros!;
    }
    if (conjugacion.indicativePreteriteEllos != null &&
        conjugacion.indicativePreteriteEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativePreteriteEllos] =
          conjugacion.indicativePreteriteEllos!;
    }
    if (conjugacion.indicativeImperfectYo != null &&
        conjugacion.indicativeImperfectYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfectYo] =
          conjugacion.indicativeImperfectYo!;
    }
    if (conjugacion.indicativeImperfectTu != null &&
        conjugacion.indicativeImperfectTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfectTu] =
          conjugacion.indicativeImperfectTu!;
    }
    if (conjugacion.indicativeImperfectEl != null &&
        conjugacion.indicativeImperfectEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfectEl] =
          conjugacion.indicativeImperfectEl!;
    }
    if (conjugacion.indicativeImperfectNosotros != null &&
        conjugacion.indicativeImperfectNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfectNosotros] =
          conjugacion.indicativeImperfectNosotros!;
    }
    if (conjugacion.indicativeImperfectVosotros != null &&
        conjugacion.indicativeImperfectVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfectVosotros] =
          conjugacion.indicativeImperfectVosotros!;
    }
    if (conjugacion.indicativeImperfectEllos != null &&
        conjugacion.indicativeImperfectEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativeImperfectEllos] =
          conjugacion.indicativeImperfectEllos!;
    }
    if (conjugacion.indicativeFutureYo != null &&
        conjugacion.indicativeFutureYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFutureYo] =
          conjugacion.indicativeFutureYo!;
    }
    if (conjugacion.indicativeFutureTu != null &&
        conjugacion.indicativeFutureTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFutureTu] =
          conjugacion.indicativeFutureTu!;
    }
    if (conjugacion.indicativeFutureEl != null &&
        conjugacion.indicativeFutureEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFutureEl] =
          conjugacion.indicativeFutureEl!;
    }
    if (conjugacion.indicativeFutureNosotros != null &&
        conjugacion.indicativeFutureNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFutureNosotros] =
          conjugacion.indicativeFutureNosotros!;
    }
    if (conjugacion.indicativeFutureVosotros != null &&
        conjugacion.indicativeFutureVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFutureVosotros] =
          conjugacion.indicativeFutureVosotros!;
    }
    if (conjugacion.indicativeFutureEllos != null &&
        conjugacion.indicativeFutureEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativeFutureEllos] =
          conjugacion.indicativeFutureEllos!;
    }
    if (conjugacion.indicativeConditionalYo != null &&
        conjugacion.indicativeConditionalYo!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditionalYo] =
          conjugacion.indicativeConditionalYo!;
    }
    if (conjugacion.indicativeConditionalTu != null &&
        conjugacion.indicativeConditionalTu!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditionalTu] =
          conjugacion.indicativeConditionalTu!;
    }
    if (conjugacion.indicativeConditionalEl != null &&
        conjugacion.indicativeConditionalEl!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditionalEl] =
          conjugacion.indicativeConditionalEl!;
    }
    if (conjugacion.indicativeConditionalNosotros != null &&
        conjugacion.indicativeConditionalNosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditionalNosotros] =
          conjugacion.indicativeConditionalNosotros!;
    }
    if (conjugacion.indicativeConditionalVosotros != null &&
        conjugacion.indicativeConditionalVosotros!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditionalVosotros] =
          conjugacion.indicativeConditionalVosotros!;
    }
    if (conjugacion.indicativeConditionalEllos != null &&
        conjugacion.indicativeConditionalEllos!.isNotEmpty) {
      res[MoodTenseSubject.indicativeConditionalEllos] =
          conjugacion.indicativeConditionalEllos!;
    }
    if (conjugacion.imperativeTu != null &&
        conjugacion.imperativeTu!.isNotEmpty) {
      res[MoodTenseSubject.imperativeTu] = conjugacion.imperativeTu!;
    }
    if (conjugacion.imperativeEl != null &&
        conjugacion.imperativeEl!.isNotEmpty) {
      res[MoodTenseSubject.imperativeEl] = conjugacion.imperativeEl!;
    }
    if (conjugacion.imperativeNosotros != null &&
        conjugacion.imperativeNosotros!.isNotEmpty) {
      res[MoodTenseSubject.imperativeNosotros] =
          conjugacion.imperativeNosotros!;
    }
    if (conjugacion.imperativeVosotros != null &&
        conjugacion.imperativeVosotros!.isNotEmpty) {
      res[MoodTenseSubject.imperativeVosotros] =
          conjugacion.imperativeVosotros!;
    }
    if (conjugacion.imperativeEllos != null &&
        conjugacion.imperativeEllos!.isNotEmpty) {
      res[MoodTenseSubject.imperativeEllos] = conjugacion.imperativeEllos!;
    }
    if (conjugacion.subjunctivePresentYo != null &&
        conjugacion.subjunctivePresentYo!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresentYo] =
          conjugacion.subjunctivePresentYo!;
    }
    if (conjugacion.subjunctivePresentTu != null &&
        conjugacion.subjunctivePresentTu!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresentTu] =
          conjugacion.subjunctivePresentTu!;
    }
    if (conjugacion.subjunctivePresentEl != null &&
        conjugacion.subjunctivePresentEl!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresentEl] =
          conjugacion.subjunctivePresentEl!;
    }
    if (conjugacion.subjunctivePresentNosotros != null &&
        conjugacion.subjunctivePresentNosotros!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresentNosotros] =
          conjugacion.subjunctivePresentNosotros!;
    }
    if (conjugacion.subjunctivePresentVosotros != null &&
        conjugacion.subjunctivePresentVosotros!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresentVosotros] =
          conjugacion.subjunctivePresentVosotros!;
    }
    if (conjugacion.subjunctivePresentEllos != null &&
        conjugacion.subjunctivePresentEllos!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePresentEllos] =
          conjugacion.subjunctivePresentEllos!;
    }
    if (conjugacion.subjunctivePastYo != null &&
        conjugacion.subjunctivePastYo!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePastYo] = conjugacion.subjunctivePastYo!;
    }
    if (conjugacion.subjunctivePastTu != null &&
        conjugacion.subjunctivePastTu!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePastTu] = conjugacion.subjunctivePastTu!;
    }
    if (conjugacion.subjunctivePastEl != null &&
        conjugacion.subjunctivePastEl!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePastEl] = conjugacion.subjunctivePastEl!;
    }
    if (conjugacion.subjunctivePastNosotros != null &&
        conjugacion.subjunctivePastNosotros!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePastNosotros] =
          conjugacion.subjunctivePastNosotros!;
    }
    if (conjugacion.subjunctivePastVosotros != null &&
        conjugacion.subjunctivePastVosotros!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePastVosotros] =
          conjugacion.subjunctivePastVosotros!;
    }
    if (conjugacion.subjunctivePastEllos != null &&
        conjugacion.subjunctivePastEllos!.isNotEmpty) {
      res[MoodTenseSubject.subjunctivePastEllos] =
          conjugacion.subjunctivePastEllos!;
    }
    return res;
  }

  /// Convert TableData fields to complete conjugation map
  static Map<MoodTense, TenseConjugacion> _convertToConjugations(
      EspConjugationTableData data) {
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
