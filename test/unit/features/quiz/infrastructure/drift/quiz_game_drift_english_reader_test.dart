import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/quiz_game_drift_english_reader.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_infrastructure_error.dart';

void main() {
  test('maps a missing Drift row to the established placeholder forms',
      () async {
    final reader = QuizGameDriftEnglishReader.reading((_) async => null);

    final result = await reader.readEnglishConjugation(42);

    expect(result.dataOrNull, {
      EnglishMoodTense.participlePresent.toString(): 'V-ing',
      EnglishMoodTense.participlePast.toString(): 'V-en',
      EnglishMoodTense.indicativePresent.toString(): 'V',
      EnglishMoodTense.indicativePresent3rd.toString(): 'Vs',
      EnglishMoodTense.indicativePast.toString(): 'V-ed',
    });
  });

  test('maps persisted Drift fields without changing their output wire keys',
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

    expect(result.dataOrNull?[EnglishMoodTense.indicativePresent.toString()],
        'speak');
    expect(result.dataOrNull?[EnglishMoodTense.indicativePresent3rd.toString()],
        'speaks');
  });

  test('normalizes a Drift exception to a Quiz-owned database error', () async {
    final reader = QuizGameDriftEnglishReader.reading(
        (_) => throw StateError('database unavailable'));

    final result = await reader.readEnglishConjugation(42);

    expect(result.errorOrNull, isA<QuizGameDatabaseError>());
  });
}
