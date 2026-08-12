import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;

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
  subjunctivePast
}

enum QuizSubject { yo, tu, el, nosotros, vosotros, ellos }

enum QuizEnglishMoodTense {
  participlePresent,
  participlePast,
  indicativePresent,
  indicativePresent3rd,
  indicativePast
}

enum QuizEnglishSubject { i, you, he, we, they }

/// Quiz-owned, wire-format-free Spanish conjugation data.
final class QuizConjugation {
  QuizConjugation(
      {required this.word,
      required Map<QuizMoodTense, Map<QuizSubject, String>> forms})
      : forms = Map<QuizMoodTense, Map<QuizSubject, String>>.unmodifiable({
          for (final e in forms.entries)
            e.key: Map<QuizSubject, String>.unmodifiable(e.value),
        });
  final CatalogWordRef word;
  final Map<QuizMoodTense, Map<QuizSubject, String>> forms;
  String? form(QuizMoodTense tense, QuizSubject subject) =>
      forms[tense]?[subject];
}

/// Typed English verb forms used by Quiz prompts.
final class QuizEnglishConjugation {
  QuizEnglishConjugation(Map<QuizEnglishMoodTense, String> forms)
      : _forms = Map.unmodifiable(forms);
  final Map<QuizEnglishMoodTense, String> _forms;
  String? form(QuizEnglishMoodTense tense) => _forms[tense];
}

/// Typed prompt templates indexed by the Quiz tense, never JSON keys.
final class QuizEnglishPromptGuide {
  QuizEnglishPromptGuide(Map<QuizMoodTense, String> templates)
      : _templates = Map.unmodifiable(templates);
  final Map<QuizMoodTense, String> _templates;
  String? templateFor(QuizMoodTense tense) => _templates[tense];
}

/// Typed forms of `be` used where the English prompt requires an auxiliary.
final class QuizBeConjugation {
  QuizBeConjugation(
      Map<QuizEnglishMoodTense, Map<QuizEnglishSubject, String>> forms)
      : _forms = Map<QuizEnglishMoodTense,
            Map<QuizEnglishSubject, String>>.unmodifiable({
          for (final e in forms.entries)
            e.key: Map<QuizEnglishSubject, String>.unmodifiable(e.value),
        });
  final Map<QuizEnglishMoodTense, Map<QuizEnglishSubject, String>> _forms;
  String? form(QuizEnglishMoodTense tense, QuizEnglishSubject subject) =>
      _forms[tense]?[subject];
}
