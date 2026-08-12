import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';

extension QuizMoodTensePresentation on QuizMoodTense {
  String get japaneseLabel => switch (this) {
        QuizMoodTense.participlePresent => '現在分詞',
        QuizMoodTense.participlePast => '過去分詞',
        _ => '',
      };

  String get tenseName => switch (this) {
        QuizMoodTense.participlePresent ||
        QuizMoodTense.indicativePresent =>
          '現在',
        QuizMoodTense.participlePast || QuizMoodTense.subjunctivePast => '過去',
        QuizMoodTense.indicativePreterite => '点過去',
        QuizMoodTense.indicativeImperfect => '線過去',
        QuizMoodTense.indicativeFuture => '未来',
        QuizMoodTense.indicativeConditional => '過去未来',
        QuizMoodTense.imperative => '',
        QuizMoodTense.subjunctivePresent => '現在',
      };

  String get moodName => switch (this) {
        QuizMoodTense.participlePresent || QuizMoodTense.participlePast => '分詞',
        QuizMoodTense.indicativePresent ||
        QuizMoodTense.indicativePreterite ||
        QuizMoodTense.indicativeImperfect ||
        QuizMoodTense.indicativeFuture ||
        QuizMoodTense.indicativeConditional =>
          '直説法',
        QuizMoodTense.imperative => '命令法',
        QuizMoodTense.subjunctivePresent ||
        QuizMoodTense.subjunctivePast =>
          '接続法',
      };

  QuizEnglishMoodTense get englishEquivalent => switch (this) {
        QuizMoodTense.participlePresent =>
          QuizEnglishMoodTense.participlePresent,
        QuizMoodTense.participlePast => QuizEnglishMoodTense.participlePast,
        QuizMoodTense.indicativePreterite ||
        QuizMoodTense.subjunctivePast =>
          QuizEnglishMoodTense.indicativePast,
        _ => QuizEnglishMoodTense.indicativePresent,
      };
}

extension QuizSubjectPresentation on QuizSubject {
  String get displaySpanish => switch (this) {
        QuizSubject.yo => 'Yo',
        QuizSubject.tu => 'Tú',
        QuizSubject.el => 'Él/Ella/Usted',
        QuizSubject.nosotros => 'Nosotr@s',
        QuizSubject.vosotros => 'Vosotr@s',
        QuizSubject.ellos => 'Ell@s/Ustedes',
      };

  QuizEnglishSubject get englishEquivalent => switch (this) {
        QuizSubject.yo => QuizEnglishSubject.i,
        QuizSubject.tu || QuizSubject.vosotros => QuizEnglishSubject.you,
        QuizSubject.el => QuizEnglishSubject.he,
        QuizSubject.nosotros => QuizEnglishSubject.we,
        QuizSubject.ellos => QuizEnglishSubject.they,
      };
}
