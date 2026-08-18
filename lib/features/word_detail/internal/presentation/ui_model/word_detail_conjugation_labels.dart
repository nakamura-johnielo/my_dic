import 'package:my_dic/features/word_detail/port/word_detail.dart';

extension WordDetailMoodTenseLabels on WordDetailMoodTense {
  String get moodName => switch (this) {
        WordDetailMoodTense.participlePresent ||
        WordDetailMoodTense.participlePast =>
          '分詞',
        WordDetailMoodTense.indicativePresent ||
        WordDetailMoodTense.indicativePreterite ||
        WordDetailMoodTense.indicativeImperfect ||
        WordDetailMoodTense.indicativeFuture ||
        WordDetailMoodTense.indicativeConditional =>
          '直説法',
        WordDetailMoodTense.imperative => '命令法',
        WordDetailMoodTense.subjunctivePresent ||
        WordDetailMoodTense.subjunctivePast =>
          '接続法',
      };

  String get tenseName => switch (this) {
        WordDetailMoodTense.participlePresent => '現在',
        WordDetailMoodTense.participlePast => '過去',
        WordDetailMoodTense.indicativePresent ||
        WordDetailMoodTense.subjunctivePresent =>
          '現在',
        WordDetailMoodTense.indicativePreterite => '点過去',
        WordDetailMoodTense.indicativeImperfect => '線過去',
        WordDetailMoodTense.indicativeFuture => '未来',
        WordDetailMoodTense.indicativeConditional => '過去未来',
        WordDetailMoodTense.imperative => '',
        WordDetailMoodTense.subjunctivePast => '過去',
      };

  String get label => switch (this) {
        WordDetailMoodTense.participlePresent => '現在分詞',
        WordDetailMoodTense.participlePast => '過去分詞',
        _ => '【$moodName】 $tenseName',
      };
}

extension WordDetailSubjectLabels on WordDetailSubject {
  String get displayEsp => switch (this) {
        WordDetailSubject.yo => 'Yo',
        WordDetailSubject.tu => 'Tú',
        WordDetailSubject.el => 'Él/Ella/Usted',
        WordDetailSubject.nosotros => 'Nosotr@s',
        WordDetailSubject.vosotros => 'Vosotr@s',
        WordDetailSubject.ellos => 'Ell@s/Ustedes',
      };
}

const wordDetailSubjectOrder = <WordDetailSubject>[
  WordDetailSubject.yo,
  WordDetailSubject.tu,
  WordDetailSubject.el,
  WordDetailSubject.nosotros,
  WordDetailSubject.vosotros,
  WordDetailSubject.ellos,
];
