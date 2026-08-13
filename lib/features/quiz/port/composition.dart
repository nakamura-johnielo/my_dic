import 'package:my_dic/features/quiz/internal/composition/quiz_composition_factory.dart';
import 'package:my_dic/features/quiz/port/reader/quiz_candidate_reader_port.dart';
import 'package:my_dic/features/quiz/port/reader/quiz_game_reader_port.dart';

/// Opaque application-owned services required by the Quiz composition root.
///
/// The application owns their implementations and lifetimes. This public
/// contract intentionally exposes neither Riverpod, a database/DAO, nor any
/// Quiz-internal implementation type.
enum QuizDependency {
  candidateCatalogGateway,
  gameCatalogGateway,
  englishReader,
  assetReader,
}

/// Reads an application-owned dependency requested by the Quiz factory.
typedef QuizDependencyReader = T Function<T>(QuizDependency dependency);

/// The focused Quiz capabilities supplied to the presentation boundary.
final class QuizPorts {
  const QuizPorts({
    required this.candidateReader,
    required this.gameReader,
  });

  final QuizCandidateQueryPort candidateReader;
  final QuizGameQueryPort gameReader;
}

/// Assembles Quiz's internal policy graph from application-owned inputs.
QuizPorts createQuizPorts(QuizDependencyReader read) =>
    createInternalQuizPorts(read);
