import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

  test('facade exposes validated, trimmed candidate input', () {
    final query = QuizCandidateQuery(text: ' hablar ', page: 0, size: 20);
    expect(query.text, 'hablar');
    expect(() => QuizCandidateQuery(text: '', page: -1, size: 1),
        throwsArgumentError);
    expect(() => QuizCandidateQuery(text: '', page: 0, size: 0),
        throwsArgumentError);
  });

  test('facade exposes typed game and prompt values without wire maps', () {
    final conjugation = QuizConjugation(forms: {
      QuizMoodTense.indicativePresent: {QuizSubject.yo: 'hablo'},
    }, word: word);
    final english = QuizEnglishConjugation({
      QuizEnglishMoodTense.indicativePresent: 'speak',
    });
    final guide = QuizEnglishPromptGuide({
      QuizMoodTense.indicativePresent: '@ #',
    });
    final be = QuizBeConjugation({
      QuizEnglishMoodTense.indicativePresent: {QuizEnglishSubject.he: 'is'},
    });
    final outcome = QuizGameLoadOutcome.ready(QuizGameData(
      conjugation: conjugation,
      englishConjugation: english,
      promptGuide: guide,
      beConjugation: be,
    ));

    expect(conjugation.form(QuizMoodTense.indicativePresent, QuizSubject.yo),
        'hablo');
    expect(english.form(QuizEnglishMoodTense.indicativePresent), 'speak');
    expect(guide.templateFor(QuizMoodTense.indicativePresent), '@ #');
    expect(
        be.form(QuizEnglishMoodTense.indicativePresent, QuizEnglishSubject.he),
        'is');
    expect(outcome, isA<QuizGameReady>());
  });

  test(
      'business facade export closure has no framework, internal, or wire map contracts',
      () {
    final facade = File('lib/features/quiz/port/quiz.dart').readAsStringSync();
    expect(facade, isNot(contains('internal/')));
    expect(facade, isNot(contains('flutter')));
    expect(facade, isNot(contains('drift')));
    expect(facade, isNot(contains('presentation_dependencies')));
    expect(facade, isNot(contains('composition.dart')));
    expect(facade, isNot(contains("export 'catalog_gateway.dart'")));
  });
}
