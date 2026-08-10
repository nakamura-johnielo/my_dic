import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/quiz/internal/game/application/conjugation/quiz_conjugation.dart';

/// Consumer-side mapping from the Catalog contract to Quiz vocabulary.
abstract final class CatalogQuizConjugationMapper {
  static QuizConjugation fromCatalog(CatalogConjugation source) {
    return QuizConjugation(
      word: source.word,
      forms: {
        for (final tense in source.conjugations.entries)
          _moodTense(tense.key): {
            for (final form in tense.value.forms.entries)
              _subject(form.key): form.value,
          },
      },
      presentParticiple: source.participles.present,
      pastParticiple: source.participles.past,
    );
  }

  static QuizMoodTense _moodTense(CatalogMoodTense value) =>
      QuizMoodTense.values.byName(value.name);

  static QuizSubject _subject(CatalogSubject value) =>
      QuizSubject.values.byName(value.name);
}
