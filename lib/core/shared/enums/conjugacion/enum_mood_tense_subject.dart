/* 
直接法      Indicative
  現在        Present
  点過去      Preterite
  線過去      Imperfect
  未来        Future
  過去未来    Conditional
        
命令        Imperative

接続法      Subjunctive
  現在        present
  過去        past
 */

/* 
  presentParticiple,
  pastParticiple,
  indicativePresentYo, // 直接法現在
  indicativePresentTu, // 直接法現在
  indicativePresentEl, // 直接法現在
  indicativePresentNosotros, // 直接法現在
  indicativePresentVosotros, // 直接法現在
  indicativePresentEllos, // 直接法現在
  indicativePreteriteYo, // 直接法点過去
  indicativePreteriteTu, // 直接法点過去
  indicativePreteriteEl, // 直接法点過去
  indicativePreteriteNosotros, // 直接法点過去
  indicativePreteriteVosotros, // 直接法点過去
  indicativePreteriteEllos, // 直接法点過去
  indicativeImperfectYo, // 直接法線過去
  indicativeImperfectTu, // 直接法線過去
  indicativeImperfectEl, // 直接法線過去
  indicativeImperfectNosotros, // 直接法線過去
  indicativeImperfectVosotros, // 直接法線過去
  indicativeImperfectEllos, // 直接法線過去
  indicativeFutureYo, // 直接法未来
  indicativeFutureTu, // 直接法未来
  indicativeFutureEl, // 直接法未来
  indicativeFutureNosotros, // 直接法未来
  indicativeFutureVosotros, // 直接法未来
  indicativeFutureEllos, // 直接法未来
  indicativeConditionalYo, // 直接法過去未来
  indicativeConditionalTu, // 直接法過去未来
  indicativeConditionalEl, // 直接法過去未来
  indicativeConditionalNosotros, // 直接法過去未来
  indicativeConditionalVosotros, // 直接法過去未来
  indicativeConditionalEllos, // 直接法過去未来
  imperativeTu, // 命令
  imperativeEl, // 命令
  imperativeNosotros, // 命令
  imperativeVosotros, // 命令
  imperativeEllos, // 命令
  subjunctivePresentYo, // 接続法現在
  subjunctivePresentTu, // 接続法現在
  subjunctivePresentEl, // 接続法現在
  subjunctivePresentNosotros, // 接続法現在
  subjunctivePresentVosotros, // 接続法現在
  subjunctivePresentEllos, // 接続法現在
  subjunctivePastYo, // 接続法過去
  subjunctivePastTu, // 接続法過去
  subjunctivePastEl, // 接続法過去
  subjunctivePastNosotros, // 接続法過去
  subjunctivePastVosotros, // 接続法過去
  subjunctivePastEllos // 接続法過去 */

import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/shared/enums/conjugacion/subject.dart';

enum MoodTenseSubject {
  presentParticiple,
  pastParticiple,

  indicativePresentYo, // 直接法現在
  indicativePresentTu, // 直接法現在
  indicativePresentEl, // 直接法現在
  indicativePresentNosotros, // 直接法現在
  indicativePresentVosotros, // 直接法現在
  indicativePresentEllos, // 直接法現在

  indicativePreteriteYo, // 直接法点過去
  indicativePreteriteTu, // 直接法点過去
  indicativePreteriteEl, // 直接法点過去
  indicativePreteriteNosotros, // 直接法点過去
  indicativePreteriteVosotros, // 直接法点過去
  indicativePreteriteEllos, // 直接法点過去

  indicativeImperfectYo, // 直接法線過去
  indicativeImperfectTu, // 直接法線過去
  indicativeImperfectEl, // 直接法線過去
  indicativeImperfectNosotros, // 直接法線過去
  indicativeImperfectVosotros, // 直接法線過去
  indicativeImperfectEllos, // 直接法線過去

  indicativeFutureYo, // 直接法未来
  indicativeFutureTu, // 直接法未来
  indicativeFutureEl, // 直接法未来
  indicativeFutureNosotros, // 直接法未来
  indicativeFutureVosotros, // 直接法未来
  indicativeFutureEllos, // 直接法未来

  indicativeConditionalYo, // 直接法過去未来
  indicativeConditionalTu, // 直接法過去未来
  indicativeConditionalEl, // 直接法過去未来
  indicativeConditionalNosotros, // 直接法過去未来
  indicativeConditionalVosotros, // 直接法過去未来
  indicativeConditionalEllos, // 直接法過去未来

  imperativeTu, // 命令
  imperativeEl, // 命令
  imperativeNosotros, // 命令
  imperativeVosotros, // 命令
  imperativeEllos, // 命令

  subjunctivePresentYo, // 接続法現在
  subjunctivePresentTu, // 接続法現在
  subjunctivePresentEl, // 接続法現在
  subjunctivePresentNosotros, // 接続法現在
  subjunctivePresentVosotros, // 接続法現在
  subjunctivePresentEllos, // 接続法現在

  subjunctivePastYo, // 接続法過去
  subjunctivePastTu, // 接続法過去
  subjunctivePastEl, // 接続法過去
  subjunctivePastNosotros, // 接続法過去
  subjunctivePastVosotros, // 接続法過去
  subjunctivePastEllos // 接続法過去
}

extension MoodTenseSubjectExtension on MoodTenseSubject {
  String get dbColName {
    switch (this) {
      case MoodTenseSubject.presentParticiple:
        return 'present_participle';
      case MoodTenseSubject.pastParticiple:
        return 'past_participle';

      case MoodTenseSubject.indicativePresentYo:
        return 'indicative_present_yo';
      case MoodTenseSubject.indicativePresentTu:
        return 'indicative_present_tu';
      case MoodTenseSubject.indicativePresentEl:
        return 'indicative_present_el';
      case MoodTenseSubject.indicativePresentNosotros:
        return 'indicative_present_nosotros';
      case MoodTenseSubject.indicativePresentVosotros:
        return 'indicative_present_vosotros';
      case MoodTenseSubject.indicativePresentEllos: //
        return 'indicative_present_ellos';

      case MoodTenseSubject.indicativePreteriteYo: //
        return 'indicative_preterite_yo';
      case MoodTenseSubject.indicativePreteriteTu:
        return 'indicative_preterite_tu';
      case MoodTenseSubject.indicativePreteriteEl:
        return 'indicative_preterite_el';
      case MoodTenseSubject.indicativePreteriteNosotros:
        return 'indicative_preterite_nosotros';
      case MoodTenseSubject.indicativePreteriteVosotros:
        return 'indicative_preterite_vosotros';
      case MoodTenseSubject.indicativePreteriteEllos: //
        return 'indicative_preterite_ellos';

      case MoodTenseSubject.indicativeImperfectYo: //
        return 'indicative_imperfect_yo';
      case MoodTenseSubject.indicativeImperfectTu:
        return 'indicative_imperfect_tu';
      case MoodTenseSubject.indicativeImperfectEl:
        return 'indicative_imperfect_el';
      case MoodTenseSubject.indicativeImperfectNosotros:
        return 'indicative_imperfect_nosotros';
      case MoodTenseSubject.indicativeImperfectVosotros:
        return 'indicative_imperfect_vosotros';
      case MoodTenseSubject.indicativeImperfectEllos: //
        return 'indicative_imperfect_ellos';

      case MoodTenseSubject.indicativeFutureYo: //
        return 'indicative_future_yo';
      case MoodTenseSubject.indicativeFutureTu:
        return 'indicative_future_tu';
      case MoodTenseSubject.indicativeFutureEl:
        return 'indicative_future_el';
      case MoodTenseSubject.indicativeFutureNosotros:
        return 'indicative_future_nosotros';
      case MoodTenseSubject.indicativeFutureVosotros:
        return 'indicative_future_vosotros';
      case MoodTenseSubject.indicativeFutureEllos: //
        return 'indicative_future_ellos';

      case MoodTenseSubject.indicativeConditionalYo: //
        return 'indicative_conditional_yo';
      case MoodTenseSubject.indicativeConditionalTu:
        return 'indicative_conditional_tu';
      case MoodTenseSubject.indicativeConditionalEl:
        return 'indicative_conditional_el';
      case MoodTenseSubject.indicativeConditionalNosotros:
        return 'indicative_conditional_nosotros';
      case MoodTenseSubject.indicativeConditionalVosotros:
        return 'indicative_conditional_vosotros';
      case MoodTenseSubject.indicativeConditionalEllos: //
        return 'indicative_conditional_ellos';

      case MoodTenseSubject.imperativeTu: //
        return 'imperative_tu';
      case MoodTenseSubject.imperativeEl:
        return 'imperative_el';
      case MoodTenseSubject.imperativeNosotros:
        return 'imperative_nosotros';
      case MoodTenseSubject.imperativeVosotros:
        return 'imperative_vosotros';
      case MoodTenseSubject.imperativeEllos: //
        return 'imperative_ellos';

      case MoodTenseSubject.subjunctivePresentYo: //
        return 'subjunctive_present_yo';
      case MoodTenseSubject.subjunctivePresentTu:
        return 'subjunctive_present_tu';
      case MoodTenseSubject.subjunctivePresentEl:
        return 'subjunctive_present_el';
      case MoodTenseSubject.subjunctivePresentNosotros:
        return 'subjunctive_present_nosotros';
      case MoodTenseSubject.subjunctivePresentVosotros:
        return 'subjunctive_present_vosotros';
      case MoodTenseSubject.subjunctivePresentEllos: //
        return 'subjunctive_present_ellos';

      case MoodTenseSubject.subjunctivePastYo: //
        return 'subjunctive_past_yo';
      case MoodTenseSubject.subjunctivePastTu:
        return 'subjunctive_past_tu';
      case MoodTenseSubject.subjunctivePastEl:
        return 'subjunctive_past_el';
      case MoodTenseSubject.subjunctivePastNosotros:
        return 'subjunctive_past_nosotros';
      case MoodTenseSubject.subjunctivePastVosotros:
        return 'subjunctive_past_vosotros';
      case MoodTenseSubject.subjunctivePastEllos: //
        return 'subjunctive_past_ellos';
    }
  }
}

extension MoodTenseExtension on MoodTenseSubject {
  MoodTense get moodTense {
    switch (this) {
      case MoodTenseSubject.presentParticiple:
        return MoodTense.participlePresent;
      case MoodTenseSubject.pastParticiple:
        return MoodTense.participlePast;

      case MoodTenseSubject.indicativePresentYo:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresentTu:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresentEl:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresentNosotros:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresentVosotros:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresentEllos: //
        return MoodTense.indicativePresent;

      case MoodTenseSubject.indicativePreteriteYo: //
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreteriteTu:
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreteriteEl:
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreteriteNosotros:
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreteriteVosotros:
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreteriteEllos: //
        return MoodTense.indicativePreterite;

      case MoodTenseSubject.indicativeImperfectYo: //
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfectTu:
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfectEl:
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfectNosotros:
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfectVosotros:
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfectEllos: //
        return MoodTense.indicativeImperfect;

      case MoodTenseSubject.indicativeFutureYo: //
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFutureTu:
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFutureEl:
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFutureNosotros:
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFutureVosotros:
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFutureEllos: //
        return MoodTense.indicativeFuture;

      case MoodTenseSubject.indicativeConditionalYo: //
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditionalTu:
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditionalEl:
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditionalNosotros:
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditionalVosotros:
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditionalEllos: //
        return MoodTense.indicativeConditional;

      case MoodTenseSubject.imperativeTu: //
        return MoodTense.imperative;
      case MoodTenseSubject.imperativeEl:
        return MoodTense.imperative;
      case MoodTenseSubject.imperativeNosotros:
        return MoodTense.imperative;
      case MoodTenseSubject.imperativeVosotros:
        return MoodTense.imperative;
      case MoodTenseSubject.imperativeEllos: //
        return MoodTense.imperative;

      case MoodTenseSubject.subjunctivePresentYo: //
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresentTu:
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresentEl:
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresentNosotros:
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresentVosotros:
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresentEllos: //
        return MoodTense.subjunctivePresent;

      case MoodTenseSubject.subjunctivePastYo: //
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePastTu:
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePastEl:
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePastNosotros:
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePastVosotros:
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePastEllos: //
        return MoodTense.subjunctivePast;
    }
  }
}

extension SubjectExtension on MoodTenseSubject {
  Subject get subject {
    switch (this) {
      case MoodTenseSubject.presentParticiple:
        return Subject.yo;
      case MoodTenseSubject.pastParticiple:
        return Subject.yo;

      case MoodTenseSubject.indicativePresentYo:
        return Subject.yo;
      case MoodTenseSubject.indicativePresentTu:
        return Subject.tu;
      case MoodTenseSubject.indicativePresentEl:
        return Subject.el;
      case MoodTenseSubject.indicativePresentNosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativePresentVosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativePresentEllos: //
        return Subject.ellos;

      case MoodTenseSubject.indicativePreteriteYo: //
        return Subject.yo;
      case MoodTenseSubject.indicativePreteriteTu:
        return Subject.tu;
      case MoodTenseSubject.indicativePreteriteEl:
        return Subject.el;
      case MoodTenseSubject.indicativePreteriteNosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativePreteriteVosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativePreteriteEllos: //
        return Subject.ellos;

      case MoodTenseSubject.indicativeImperfectYo: //
        return Subject.yo;
      case MoodTenseSubject.indicativeImperfectTu:
        return Subject.tu;
      case MoodTenseSubject.indicativeImperfectEl:
        return Subject.el;
      case MoodTenseSubject.indicativeImperfectNosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativeImperfectVosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativeImperfectEllos: //
        return Subject.ellos;

      case MoodTenseSubject.indicativeFutureYo: //
        return Subject.yo;
      case MoodTenseSubject.indicativeFutureTu:
        return Subject.tu;
      case MoodTenseSubject.indicativeFutureEl:
        return Subject.el;
      case MoodTenseSubject.indicativeFutureNosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativeFutureVosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativeFutureEllos: //
        return Subject.ellos;

      case MoodTenseSubject.indicativeConditionalYo: //
        return Subject.yo;
      case MoodTenseSubject.indicativeConditionalTu:
        return Subject.tu;
      case MoodTenseSubject.indicativeConditionalEl:
        return Subject.el;
      case MoodTenseSubject.indicativeConditionalNosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativeConditionalVosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativeConditionalEllos: //
        return Subject.ellos;

      case MoodTenseSubject.imperativeTu: //
        return Subject.tu;
      case MoodTenseSubject.imperativeEl:
        return Subject.el;
      case MoodTenseSubject.imperativeNosotros:
        return Subject.nosotros;
      case MoodTenseSubject.imperativeVosotros:
        return Subject.vosotros;
      case MoodTenseSubject.imperativeEllos: //
        return Subject.ellos;

      case MoodTenseSubject.subjunctivePresentYo: //
        return Subject.yo;
      case MoodTenseSubject.subjunctivePresentTu:
        return Subject.tu;
      case MoodTenseSubject.subjunctivePresentEl:
        return Subject.el;
      case MoodTenseSubject.subjunctivePresentNosotros:
        return Subject.nosotros;
      case MoodTenseSubject.subjunctivePresentVosotros:
        return Subject.vosotros;
      case MoodTenseSubject.subjunctivePresentEllos: //
        return Subject.ellos;

      case MoodTenseSubject.subjunctivePastYo: //
        return Subject.yo;
      case MoodTenseSubject.subjunctivePastTu:
        return Subject.tu;
      case MoodTenseSubject.subjunctivePastEl:
        return Subject.el;
      case MoodTenseSubject.subjunctivePastNosotros:
        return Subject.nosotros;
      case MoodTenseSubject.subjunctivePastVosotros:
        return Subject.vosotros;
      case MoodTenseSubject.subjunctivePastEllos: //
        return Subject.ellos;
    }
  }
}
