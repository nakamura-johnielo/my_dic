import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/quiz/application/conjugation/catalog_quiz_conjugation_mapper.dart';
import 'package:my_dic/features/quiz/application/conjugation/quiz_conjugation.dart';

void main() {
  test('maps every Catalog tense and subject into Quiz-owned values', () {
    const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);
    final source = CatalogConjugation(
      word: word,
      conjugations: {
        for (final tense in CatalogMoodTense.values)
          tense: CatalogTenseConjugation(
            forms: {
              for (final subject in CatalogSubject.values)
                subject: '${tense.name}-${subject.name}',
            },
          ),
      },
      participles: const CatalogParticiples(
        present: 'hablando',
        past: 'hablado',
      ),
    );

    final projection = CatalogQuizConjugationMapper.fromCatalog(source);

    expect(projection.word, word);
    expect(projection.presentParticiple, 'hablando');
    expect(projection.pastParticiple, 'hablado');
    for (final tense in QuizMoodTense.values) {
      for (final subject in QuizSubject.values) {
        expect(
            projection.form(tense, subject), '${tense.name}-${subject.name}');
      }
    }
  });

  test('projection collections cannot be mutated', () {
    final source = CatalogConjugation(
      word: const CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 7,
      ),
      conjugations: {
        CatalogMoodTense.indicativePresent: CatalogTenseConjugation(
          forms: const {CatalogSubject.yo: 'hablo'},
        ),
      },
      participles: const CatalogParticiples(present: '', past: ''),
    );
    final projection = CatalogQuizConjugationMapper.fromCatalog(source);

    expect(() => projection.forms.clear(), throwsUnsupportedError);
    expect(
      () => projection.forms[QuizMoodTense.indicativePresent]!.clear(),
      throwsUnsupportedError,
    );
  });

  test('Quiz display and English-equivalence mappings preserve stable keys',
      () {
    expect(
      QuizMoodTense.values.map((value) => value.name),
      CatalogMoodTense.values.map((value) => value.name),
    );
    expect(
      QuizSubject.values.map((value) => value.name),
      CatalogSubject.values.map((value) => value.name),
    );
    expect(
      QuizMoodTense.indicativePreterite.englishEquivalent.wireKey,
      'EnglishMoodTense.indicativePast',
    );
    expect(
      QuizMoodTense.indicativePresent.guideKey,
      'MoodTense.indicativePresent',
    );
    expect(
      QuizSubject.el.englishEquivalent.wireKey,
      'EnglishSubject.he',
    );
    expect(QuizSubject.tu.displaySpanish, 'Tú');
    expect(QuizMoodTense.subjunctivePast.japaneseLabel, '接続法過去');
  });
}
