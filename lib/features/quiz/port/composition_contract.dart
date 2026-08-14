import 'query/quiz_candidate_reader_port.dart';
import 'query/quiz_game_reader_port.dart';

/// The complete Quiz capabilities supplied to an application scope.
final class QuizPorts {
  const QuizPorts({
    required this.candidateReader,
    required this.gameReader,
  });

  final QuizCandidateQueryPort candidateReader;
  final QuizGameQueryPort gameReader;
}
