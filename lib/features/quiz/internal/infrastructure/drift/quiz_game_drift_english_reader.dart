import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_english_reader.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/dao/es_en_conjugacion_dao.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_infrastructure_error.dart';
import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';

/// Quiz 英語活用形境界の Drift ベース実装。
final class QuizGameDriftEnglishReader implements QuizGameEnglishReader {
  QuizGameDriftEnglishReader(EsEnConjugacionDao dao)
      : _readRow = dao.getEnglishConjById;

  QuizGameDriftEnglishReader.reading(
      Future<EsEnConjugacionTableData?> Function(int) readRow)
      : _readRow = readRow;

  final Future<EsEnConjugacionTableData?> Function(int) _readRow;

  @override
  Future<Result<QuizEnglishConjugation>> readEnglishConjugation(
    int wordId,
  ) async {
    try {
      final row = await _readRow(wordId);
      return Result.success(QuizEnglishConjugation({
        QuizEnglishMoodTense.participlePresent: row?.presentP ?? 'V-ing',
        QuizEnglishMoodTense.participlePast: row?.pastP ?? 'V-en',
        QuizEnglishMoodTense.indicativePresent: row?.english ?? 'V',
        QuizEnglishMoodTense.indicativePresent3rd: row?.present3rd ?? 'Vs',
        QuizEnglishMoodTense.indicativePast: row?.past ?? 'V-ed',
      }));
    } on Object catch (error, stackTrace) {
      return Result.failure(QuizGameDatabaseError(
        operation: 'read English conjugation for word $wordId',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
