import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'candidate_source.dart';

/// App composition supplies the Catalog-backed Quiz candidate source.
final quizCandidateSourceDependencyProvider = Provider<QuizCandidateSource>(
  (_) => throw StateError('QuizCandidateSource dependency was not supplied.'),
);
