import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_english_reader.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/dao/es_en_conjugacion_dao.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_infrastructure_error.dart';

/// Drift-backed implementation of the Quiz English-conjugation seam.
final class QuizGameDriftEnglishReader implements QuizGameEnglishReader {
  QuizGameDriftEnglishReader(EsEnConjugacionDao dao)
      : _readRow = dao.getEnglishConjById;

  QuizGameDriftEnglishReader.reading(
      Future<EsEnConjugacionTableData?> Function(int) readRow)
      : _readRow = readRow;

  final Future<EsEnConjugacionTableData?> Function(int) _readRow;

  @override
  Future<Result<Map<String, String>>> readEnglishConjugation(int wordId) async {
    try {
      final row = await _readRow(wordId);
      return Result.success({
        EnglishMoodTense.participlePresent.toString(): row?.presentP ?? 'V-ing',
        EnglishMoodTense.participlePast.toString(): row?.pastP ?? 'V-en',
        EnglishMoodTense.indicativePresent.toString(): row?.english ?? 'V',
        EnglishMoodTense.indicativePresent3rd.toString():
            row?.present3rd ?? 'Vs',
        EnglishMoodTense.indicativePast.toString(): row?.past ?? 'V-ed',
      });
    } on Object catch (error, stackTrace) {
      return Result.failure(QuizGameDatabaseError(
        operation: 'read English conjugation for word $wordId',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
