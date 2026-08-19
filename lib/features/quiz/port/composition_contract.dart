import 'query/quiz_candidate_reader_port.dart';
import 'query/quiz_game_reader_port.dart';

/// アプリケーションスコープに提供される Quiz 機能一式。
final class QuizPorts {
  const QuizPorts({
    required this.candidateReader,
    required this.gameReader,
  });

  final QuizCandidateQueryPort candidateReader;
  final QuizGameQueryPort gameReader;
}
