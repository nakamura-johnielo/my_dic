import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'composition.dart';
import 'reader/quiz_candidate_reader_port.dart';
import 'reader/quiz_game_reader_port.dart';

/// App composition supplies the scope-stable focused Quiz capabilities here.
final quizPortsDependencyProvider = Provider<QuizPorts>(
  (_) => throw StateError('QuizPorts dependency was not supplied.'),
);

final quizCandidateReaderDependencyProvider = Provider<QuizCandidateReaderPort>(
  (ref) => ref.watch(quizPortsDependencyProvider).candidateReader,
);

final quizGameReaderDependencyProvider = Provider<QuizGameReaderPort>(
  (ref) => ref.watch(quizPortsDependencyProvider).gameReader,
);
