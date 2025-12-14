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
  present_participle,
  past_participle,
  indicativePresent_yo, // 直接法現在
  indicativePresent_tu, // 直接法現在
  indicativePresent_el, // 直接法現在
  indicativePresent_nosotros, // 直接法現在
  indicativePresent_vosotros, // 直接法現在
  indicativePresent_ellos, // 直接法現在
  indicativePreterite_yo, // 直接法点過去
  indicativePreterite_tu, // 直接法点過去
  indicativePreterite_el, // 直接法点過去
  indicativePreterite_nosotros, // 直接法点過去
  indicativePreterite_vosotros, // 直接法点過去
  indicativePreterite_ellos, // 直接法点過去
  indicativeImperfect_yo, // 直接法線過去
  indicativeImperfect_tu, // 直接法線過去
  indicativeImperfect_el, // 直接法線過去
  indicativeImperfect_nosotros, // 直接法線過去
  indicativeImperfect_vosotros, // 直接法線過去
  indicativeImperfect_ellos, // 直接法線過去
  indicativeFuture_yo, // 直接法未来
  indicativeFuture_tu, // 直接法未来
  indicativeFuture_el, // 直接法未来
  indicativeFuture_nosotros, // 直接法未来
  indicativeFuture_vosotros, // 直接法未来
  indicativeFuture_ellos, // 直接法未来
  indicativeConditional_yo, // 直接法過去未来
  indicativeConditional_tu, // 直接法過去未来
  indicativeConditional_el, // 直接法過去未来
  indicativeConditional_nosotros, // 直接法過去未来
  indicativeConditional_vosotros, // 直接法過去未来
  indicativeConditional_ellos, // 直接法過去未来
  imperative_tu, // 命令
  imperative_el, // 命令
  imperative_nosotros, // 命令
  imperative_vosotros, // 命令
  imperative_ellos, // 命令
  subjunctivePresent_yo, // 接続法現在
  subjunctivePresent_tu, // 接続法現在
  subjunctivePresent_el, // 接続法現在
  subjunctivePresent_nosotros, // 接続法現在
  subjunctivePresent_vosotros, // 接続法現在
  subjunctivePresent_ellos, // 接続法現在
  subjunctivePast_yo, // 接続法過去
  subjunctivePast_tu, // 接続法過去
  subjunctivePast_el, // 接続法過去
  subjunctivePast_nosotros, // 接続法過去
  subjunctivePast_vosotros, // 接続法過去
  subjunctivePast_ellos // 接続法過去 */

import 'package:my_dic/core/common/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/common/enums/conjugacion/subject.dart';

enum MoodTenseSubject {
  present_participle,
  past_participle,

  indicativePresent_yo, // 直接法現在
  indicativePresent_tu, // 直接法現在
  indicativePresent_el, // 直接法現在
  indicativePresent_nosotros, // 直接法現在
  indicativePresent_vosotros, // 直接法現在
  indicativePresent_ellos, // 直接法現在

  indicativePreterite_yo, // 直接法点過去
  indicativePreterite_tu, // 直接法点過去
  indicativePreterite_el, // 直接法点過去
  indicativePreterite_nosotros, // 直接法点過去
  indicativePreterite_vosotros, // 直接法点過去
  indicativePreterite_ellos, // 直接法点過去

  indicativeImperfect_yo, // 直接法線過去
  indicativeImperfect_tu, // 直接法線過去
  indicativeImperfect_el, // 直接法線過去
  indicativeImperfect_nosotros, // 直接法線過去
  indicativeImperfect_vosotros, // 直接法線過去
  indicativeImperfect_ellos, // 直接法線過去

  indicativeFuture_yo, // 直接法未来
  indicativeFuture_tu, // 直接法未来
  indicativeFuture_el, // 直接法未来
  indicativeFuture_nosotros, // 直接法未来
  indicativeFuture_vosotros, // 直接法未来
  indicativeFuture_ellos, // 直接法未来

  indicativeConditional_yo, // 直接法過去未来
  indicativeConditional_tu, // 直接法過去未来
  indicativeConditional_el, // 直接法過去未来
  indicativeConditional_nosotros, // 直接法過去未来
  indicativeConditional_vosotros, // 直接法過去未来
  indicativeConditional_ellos, // 直接法過去未来

  imperative_tu, // 命令
  imperative_el, // 命令
  imperative_nosotros, // 命令
  imperative_vosotros, // 命令
  imperative_ellos, // 命令

  subjunctivePresent_yo, // 接続法現在
  subjunctivePresent_tu, // 接続法現在
  subjunctivePresent_el, // 接続法現在
  subjunctivePresent_nosotros, // 接続法現在
  subjunctivePresent_vosotros, // 接続法現在
  subjunctivePresent_ellos, // 接続法現在

  subjunctivePast_yo, // 接続法過去
  subjunctivePast_tu, // 接続法過去
  subjunctivePast_el, // 接続法過去
  subjunctivePast_nosotros, // 接続法過去
  subjunctivePast_vosotros, // 接続法過去
  subjunctivePast_ellos // 接続法過去
}

extension MoodTenseSubjectExtension on MoodTenseSubject {
  String get dbColName {
    switch (this) {
      case MoodTenseSubject.present_participle:
        return 'present_participle';
      case MoodTenseSubject.past_participle:
        return 'past_participle';

      case MoodTenseSubject.indicativePresent_yo:
        return 'indicative_present_yo';
      case MoodTenseSubject.indicativePresent_tu:
        return 'indicative_present_tu';
      case MoodTenseSubject.indicativePresent_el:
        return 'indicative_present_el';
      case MoodTenseSubject.indicativePresent_nosotros:
        return 'indicative_present_nosotros';
      case MoodTenseSubject.indicativePresent_vosotros:
        return 'indicative_present_vosotros';
      case MoodTenseSubject.indicativePresent_ellos: //
        return 'indicative_present_ellos';

      case MoodTenseSubject.indicativePreterite_yo: //
        return 'indicative_preterite_yo';
      case MoodTenseSubject.indicativePreterite_tu:
        return 'indicative_preterite_tu';
      case MoodTenseSubject.indicativePreterite_el:
        return 'indicative_preterite_el';
      case MoodTenseSubject.indicativePreterite_nosotros:
        return 'indicative_preterite_nosotros';
      case MoodTenseSubject.indicativePreterite_vosotros:
        return 'indicative_preterite_vosotros';
      case MoodTenseSubject.indicativePreterite_ellos: //
        return 'indicative_preterite_ellos';

      case MoodTenseSubject.indicativeImperfect_yo: //
        return 'indicative_imperfect_yo';
      case MoodTenseSubject.indicativeImperfect_tu:
        return 'indicative_imperfect_tu';
      case MoodTenseSubject.indicativeImperfect_el:
        return 'indicative_imperfect_el';
      case MoodTenseSubject.indicativeImperfect_nosotros:
        return 'indicative_imperfect_nosotros';
      case MoodTenseSubject.indicativeImperfect_vosotros:
        return 'indicative_imperfect_vosotros';
      case MoodTenseSubject.indicativeImperfect_ellos: //
        return 'indicative_imperfect_ellos';

      case MoodTenseSubject.indicativeFuture_yo: //
        return 'indicative_future_yo';
      case MoodTenseSubject.indicativeFuture_tu:
        return 'indicative_future_tu';
      case MoodTenseSubject.indicativeFuture_el:
        return 'indicative_future_el';
      case MoodTenseSubject.indicativeFuture_nosotros:
        return 'indicative_future_nosotros';
      case MoodTenseSubject.indicativeFuture_vosotros:
        return 'indicative_future_vosotros';
      case MoodTenseSubject.indicativeFuture_ellos: //
        return 'indicative_future_ellos';

      case MoodTenseSubject.indicativeConditional_yo: //
        return 'indicative_conditional_yo';
      case MoodTenseSubject.indicativeConditional_tu:
        return 'indicative_conditional_tu';
      case MoodTenseSubject.indicativeConditional_el:
        return 'indicative_conditional_el';
      case MoodTenseSubject.indicativeConditional_nosotros:
        return 'indicative_conditional_nosotros';
      case MoodTenseSubject.indicativeConditional_vosotros:
        return 'indicative_conditional_vosotros';
      case MoodTenseSubject.indicativeConditional_ellos: //
        return 'indicative_conditional_ellos';

      case MoodTenseSubject.imperative_tu: //
        return 'imperative_tu';
      case MoodTenseSubject.imperative_el:
        return 'imperative_el';
      case MoodTenseSubject.imperative_nosotros:
        return 'imperative_nosotros';
      case MoodTenseSubject.imperative_vosotros:
        return 'imperative_vosotros';
      case MoodTenseSubject.imperative_ellos: //
        return 'imperative_ellos';

      case MoodTenseSubject.subjunctivePresent_yo: //
        return 'subjunctive_present_yo';
      case MoodTenseSubject.subjunctivePresent_tu:
        return 'subjunctive_present_tu';
      case MoodTenseSubject.subjunctivePresent_el:
        return 'subjunctive_present_el';
      case MoodTenseSubject.subjunctivePresent_nosotros:
        return 'subjunctive_present_nosotros';
      case MoodTenseSubject.subjunctivePresent_vosotros:
        return 'subjunctive_present_vosotros';
      case MoodTenseSubject.subjunctivePresent_ellos: //
        return 'subjunctive_present_ellos';

      case MoodTenseSubject.subjunctivePast_yo: //
        return 'subjunctive_past_yo';
      case MoodTenseSubject.subjunctivePast_tu:
        return 'subjunctive_past_tu';
      case MoodTenseSubject.subjunctivePast_el:
        return 'subjunctive_past_el';
      case MoodTenseSubject.subjunctivePast_nosotros:
        return 'subjunctive_past_nosotros';
      case MoodTenseSubject.subjunctivePast_vosotros:
        return 'subjunctive_past_vosotros';
      case MoodTenseSubject.subjunctivePast_ellos: //
        return 'subjunctive_past_ellos';
    }
  }
}

extension MoodTenseExtension on MoodTenseSubject {
  MoodTense get moodTense {
    switch (this) {
      case MoodTenseSubject.present_participle:
        return MoodTense.participlePresent;
      case MoodTenseSubject.past_participle:
        return MoodTense.participlePast;

      case MoodTenseSubject.indicativePresent_yo:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresent_tu:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresent_el:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresent_nosotros:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresent_vosotros:
        return MoodTense.indicativePresent;
      case MoodTenseSubject.indicativePresent_ellos: //
        return MoodTense.indicativePresent;

      case MoodTenseSubject.indicativePreterite_yo: //
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreterite_tu:
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreterite_el:
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreterite_nosotros:
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreterite_vosotros:
        return MoodTense.indicativePreterite;
      case MoodTenseSubject.indicativePreterite_ellos: //
        return MoodTense.indicativePreterite;

      case MoodTenseSubject.indicativeImperfect_yo: //
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfect_tu:
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfect_el:
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfect_nosotros:
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfect_vosotros:
        return MoodTense.indicativeImperfect;
      case MoodTenseSubject.indicativeImperfect_ellos: //
        return MoodTense.indicativeImperfect;

      case MoodTenseSubject.indicativeFuture_yo: //
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFuture_tu:
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFuture_el:
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFuture_nosotros:
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFuture_vosotros:
        return MoodTense.indicativeFuture;
      case MoodTenseSubject.indicativeFuture_ellos: //
        return MoodTense.indicativeFuture;

      case MoodTenseSubject.indicativeConditional_yo: //
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditional_tu:
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditional_el:
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditional_nosotros:
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditional_vosotros:
        return MoodTense.indicativeConditional;
      case MoodTenseSubject.indicativeConditional_ellos: //
        return MoodTense.indicativeConditional;

      case MoodTenseSubject.imperative_tu: //
        return MoodTense.imperative;
      case MoodTenseSubject.imperative_el:
        return MoodTense.imperative;
      case MoodTenseSubject.imperative_nosotros:
        return MoodTense.imperative;
      case MoodTenseSubject.imperative_vosotros:
        return MoodTense.imperative;
      case MoodTenseSubject.imperative_ellos: //
        return MoodTense.imperative;

      case MoodTenseSubject.subjunctivePresent_yo: //
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresent_tu:
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresent_el:
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresent_nosotros:
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresent_vosotros:
        return MoodTense.subjunctivePresent;
      case MoodTenseSubject.subjunctivePresent_ellos: //
        return MoodTense.subjunctivePresent;

      case MoodTenseSubject.subjunctivePast_yo: //
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePast_tu:
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePast_el:
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePast_nosotros:
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePast_vosotros:
        return MoodTense.subjunctivePast;
      case MoodTenseSubject.subjunctivePast_ellos: //
        return MoodTense.subjunctivePast;
    }
  }
}

extension SubjectExtension on MoodTenseSubject {
  Subject get subject {
    switch (this) {
      case MoodTenseSubject.present_participle:
        return Subject.yo;
      case MoodTenseSubject.past_participle:
        return Subject.yo;

      case MoodTenseSubject.indicativePresent_yo:
        return Subject.yo;
      case MoodTenseSubject.indicativePresent_tu:
        return Subject.tu;
      case MoodTenseSubject.indicativePresent_el:
        return Subject.el;
      case MoodTenseSubject.indicativePresent_nosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativePresent_vosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativePresent_ellos: //
        return Subject.ellos;

      case MoodTenseSubject.indicativePreterite_yo: //
        return Subject.yo;
      case MoodTenseSubject.indicativePreterite_tu:
        return Subject.tu;
      case MoodTenseSubject.indicativePreterite_el:
        return Subject.el;
      case MoodTenseSubject.indicativePreterite_nosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativePreterite_vosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativePreterite_ellos: //
        return Subject.ellos;

      case MoodTenseSubject.indicativeImperfect_yo: //
        return Subject.yo;
      case MoodTenseSubject.indicativeImperfect_tu:
        return Subject.tu;
      case MoodTenseSubject.indicativeImperfect_el:
        return Subject.el;
      case MoodTenseSubject.indicativeImperfect_nosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativeImperfect_vosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativeImperfect_ellos: //
        return Subject.ellos;

      case MoodTenseSubject.indicativeFuture_yo: //
        return Subject.yo;
      case MoodTenseSubject.indicativeFuture_tu:
        return Subject.tu;
      case MoodTenseSubject.indicativeFuture_el:
        return Subject.el;
      case MoodTenseSubject.indicativeFuture_nosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativeFuture_vosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativeFuture_ellos: //
        return Subject.ellos;

      case MoodTenseSubject.indicativeConditional_yo: //
        return Subject.yo;
      case MoodTenseSubject.indicativeConditional_tu:
        return Subject.tu;
      case MoodTenseSubject.indicativeConditional_el:
        return Subject.el;
      case MoodTenseSubject.indicativeConditional_nosotros:
        return Subject.nosotros;
      case MoodTenseSubject.indicativeConditional_vosotros:
        return Subject.vosotros;
      case MoodTenseSubject.indicativeConditional_ellos: //
        return Subject.ellos;

      case MoodTenseSubject.imperative_tu: //
        return Subject.tu;
      case MoodTenseSubject.imperative_el:
        return Subject.el;
      case MoodTenseSubject.imperative_nosotros:
        return Subject.nosotros;
      case MoodTenseSubject.imperative_vosotros:
        return Subject.vosotros;
      case MoodTenseSubject.imperative_ellos: //
        return Subject.ellos;

      case MoodTenseSubject.subjunctivePresent_yo: //
        return Subject.yo;
      case MoodTenseSubject.subjunctivePresent_tu:
        return Subject.tu;
      case MoodTenseSubject.subjunctivePresent_el:
        return Subject.el;
      case MoodTenseSubject.subjunctivePresent_nosotros:
        return Subject.nosotros;
      case MoodTenseSubject.subjunctivePresent_vosotros:
        return Subject.vosotros;
      case MoodTenseSubject.subjunctivePresent_ellos: //
        return Subject.ellos;

      case MoodTenseSubject.subjunctivePast_yo: //
        return Subject.yo;
      case MoodTenseSubject.subjunctivePast_tu:
        return Subject.tu;
      case MoodTenseSubject.subjunctivePast_el:
        return Subject.el;
      case MoodTenseSubject.subjunctivePast_nosotros:
        return Subject.nosotros;
      case MoodTenseSubject.subjunctivePast_vosotros:
        return Subject.vosotros;
      case MoodTenseSubject.subjunctivePast_ellos: //
        return Subject.ellos;
    }
  }
}
