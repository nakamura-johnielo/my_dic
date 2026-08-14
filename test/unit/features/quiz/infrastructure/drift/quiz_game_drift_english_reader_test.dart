import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/quiz_game_drift_english_reader.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_infrastructure_error.dart';
import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';

void main() {
  test('maps a missing Drift row to the established placeholder forms',
      () async {
    final reader = QuizGameDriftEnglishReader.reading((_) async => null);

    final result = await reader.readEnglishConjugation(42);

    final value = result.dataOrNull!;
    expect(value.form(QuizEnglishMoodTense.participlePresent), 'V-ing');
    expect(value.form(QuizEnglishMoodTense.participlePast), 'V-en');
    expect(value.form(QuizEnglishMoodTense.indicativePresent), 'V');
    expect(value.form(QuizEnglishMoodTense.indicativePresent3rd), 'Vs');
    expect(value.form(QuizEnglishMoodTense.indicativePast), 'V-ed');
  });

  test('maps persisted Drift fields to typed English forms',
      () async {
    final reader = QuizGameDriftEnglishReader.reading(
        (_) async => const EsEnConjugacionTableData(
              wordId: 42,
              english: 'speak',
              present3rd: 'speaks',
              past: 'spoke',
              presentP: 'speaking',
              pastP: 'spoken',
            ));

    final result = await reader.readEnglishConjugation(42);

    expect(
      result.dataOrNull?.form(QuizEnglishMoodTense.indicativePresent),
      'speak',
    );
    expect(
      result.dataOrNull?.form(QuizEnglishMoodTense.indicativePresent3rd),
      'speaks',
    );
  });

  test('normalizes a Drift exception to a Quiz-owned database error', () async {
    final reader = QuizGameDriftEnglishReader.reading(
        (_) => throw StateError('database unavailable'));

    final result = await reader.readEnglishConjugation(42);

    expect(result.errorOrNull, isA<QuizGameDatabaseError>());
  });
}
