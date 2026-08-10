import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_data.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_query.dart';

void main() {
  const word = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 7,
  );

  test('query is a value object over the Catalog word identity', () {
    expect(const QuizGameQuery(word), equals(const QuizGameQuery(word)));
    expect(
        const QuizGameQuery(word).hashCode, const QuizGameQuery(word).hashCode);
  });

  test('sealed result cases preserve source and value equality', () {
    const failure = QuizGameLoadResult.failure(
      source: QuizGameLoadSource.englishConjugation,
      error: 'unavailable',
    );
    expect(
      failure,
      equals(const QuizGameLoadResult.failure(
        source: QuizGameLoadSource.englishConjugation,
        error: 'unavailable',
      )),
    );
    expect(const QuizGameLoadResult.notFound(),
        equals(const QuizGameLoadResult.notFound()));
    expect(
      const QuizGameLoadResult.noConjugation(),
      equals(const QuizGameLoadResult.noConjugation()),
    );
  });

  test('ready data is immutable and compares by value', () {
    final data = QuizGameData(
      conjugation: CatalogConjugation(
        word: word,
        conjugations: const {},
        participles:
            const CatalogParticiples(present: 'hablando', past: 'hablado'),
      ),
      englishGuide: {'guide': '@ #'},
      beConjugation: {
        'present': {'EnglishSubject.he': 'is'},
      },
      englishConjugation: {'EnglishMoodTense.indicativePresent': 'speak'},
    );
    final same = QuizGameData(
      conjugation: data.conjugation,
      englishGuide: {'guide': '@ #'},
      beConjugation: {
        'present': {'EnglishSubject.he': 'is'},
      },
      englishConjugation: {'EnglishMoodTense.indicativePresent': 'speak'},
    );
    expect(
        QuizGameLoadResult.ready(data), equals(QuizGameLoadResult.ready(same)));
    expect(
        () => data.englishGuide['guide'] = 'changed', throwsUnsupportedError);
  });
}
