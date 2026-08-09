import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// Immutable Quiz-owned view of Spanish conjugation data.
final class QuizConjugation {
  QuizConjugation({
    required this.word,
    required Map<QuizMoodTense, Map<QuizSubject, String>> forms,
    required this.presentParticiple,
    required this.pastParticiple,
  }) : forms = Map<QuizMoodTense, Map<QuizSubject, String>>.unmodifiable({
          for (final entry in forms.entries)
            entry.key: Map<QuizSubject, String>.unmodifiable(entry.value),
        });

  final CatalogWordRef word;
  final Map<QuizMoodTense, Map<QuizSubject, String>> forms;
  final String presentParticiple;
  final String pastParticiple;

  String? form(QuizMoodTense moodTense, QuizSubject subject) =>
      forms[moodTense]?[subject];
}

enum QuizMoodTense {
  participlePresent,
  participlePast,
  indicativePresent,
  indicativePreterite,
  indicativeImperfect,
  indicativeFuture,
  indicativeConditional,
  imperative,
  subjunctivePresent,
  subjunctivePast,
}

enum QuizSubject { yo, tu, el, nosotros, vosotros, ellos }

enum QuizEnglishMoodTense {
  participlePresent,
  participlePast,
  indicativePresent,
  indicativePresent3rd,
  indicativePast,
}

enum QuizEnglishSubject { I, you, he, we, they }

extension QuizMoodTenseDisplay on QuizMoodTense {
  String get guideKey => 'MoodTense.$name';

  QuizEnglishMoodTense get englishEquivalent => switch (this) {
        QuizMoodTense.participlePresent =>
          QuizEnglishMoodTense.participlePresent,
        QuizMoodTense.participlePast => QuizEnglishMoodTense.participlePast,
        QuizMoodTense.indicativePresent =>
          QuizEnglishMoodTense.indicativePresent,
        QuizMoodTense.indicativePreterite =>
          QuizEnglishMoodTense.indicativePast,
        QuizMoodTense.indicativeImperfect ||
        QuizMoodTense.indicativeFuture ||
        QuizMoodTense.indicativeConditional ||
        QuizMoodTense.imperative ||
        QuizMoodTense.subjunctivePresent =>
          QuizEnglishMoodTense.indicativePresent,
        QuizMoodTense.subjunctivePast => QuizEnglishMoodTense.indicativePast,
      };

  String get japaneseLabel => switch (this) {
        QuizMoodTense.participlePresent => '現在分詞',
        QuizMoodTense.participlePast => '過去分詞',
        QuizMoodTense.indicativePresent => '直接法現在',
        QuizMoodTense.indicativePreterite => '直接法点過去',
        QuizMoodTense.indicativeImperfect => '直接法線過去',
        QuizMoodTense.indicativeFuture => '直接法未来',
        QuizMoodTense.indicativeConditional => '直接法過去未来',
        QuizMoodTense.imperative => '命令',
        QuizMoodTense.subjunctivePresent => '接続法現在',
        QuizMoodTense.subjunctivePast => '接続法過去',
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
          '直接法',
        QuizMoodTense.imperative => '命令法',
        QuizMoodTense.subjunctivePresent ||
        QuizMoodTense.subjunctivePast =>
          '接続法',
      };
}

extension QuizEnglishMoodTenseKey on QuizEnglishMoodTense {
  String get wireKey => 'EnglishMoodTense.$name';
}

extension QuizEnglishSubjectKey on QuizEnglishSubject {
  String get wireKey => 'EnglishSubject.$name';
}

extension QuizSubjectDisplay on QuizSubject {
  String get displaySpanish => switch (this) {
        QuizSubject.yo => 'Yo',
        QuizSubject.tu => 'Tú',
        QuizSubject.el => 'Él/Ella/Usted',
        QuizSubject.nosotros => 'Nosotr@s',
        QuizSubject.vosotros => 'Vosotr@s',
        QuizSubject.ellos => 'Ell@s/Ustedes',
      };

  QuizEnglishSubject get englishEquivalent => switch (this) {
        QuizSubject.yo => QuizEnglishSubject.I,
        QuizSubject.tu || QuizSubject.vosotros => QuizEnglishSubject.you,
        QuizSubject.el => QuizEnglishSubject.he,
        QuizSubject.nosotros => QuizEnglishSubject.we,
        QuizSubject.ellos => QuizEnglishSubject.they,
      };
}
