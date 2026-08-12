import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import '../model/quiz_conjugation.dart';

abstract interface class QuizGameCatalogGateway {
  Future<Result<QuizCatalogPrimaryWord?>> readPrimaryWord(CatalogWordRef word);
  Future<Result<QuizCatalogConjugation?>> readConjugation(CatalogWordRef word);
}

final class QuizCatalogPrimaryWord {
  const QuizCatalogPrimaryWord({required this.word, required this.headword});
  final CatalogWordRef word;
  final String headword;
}

/// The typed conjugation prerequisite supplied by Quiz's Catalog boundary.
///
/// This intentionally carries no Catalog DTOs or wire-format keys. The Quiz
/// application maps it to its public game model after the dependency read.
final class QuizCatalogConjugation {
  QuizCatalogConjugation({
    required this.word,
    required Map<QuizMoodTense, Map<QuizSubject, String>> forms,
  }) : forms = Map<QuizMoodTense, Map<QuizSubject, String>>.unmodifiable({
          for (final entry in forms.entries)
            entry.key: Map<QuizSubject, String>.unmodifiable(entry.value),
        });

  final CatalogWordRef word;
  final Map<QuizMoodTense, Map<QuizSubject, String>> forms;

  String? form(QuizMoodTense tense, QuizSubject subject) =>
      forms[tense]?[subject];
}
