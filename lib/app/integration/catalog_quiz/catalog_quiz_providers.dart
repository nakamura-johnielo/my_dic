import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';
import 'package:my_dic/features/quiz/port/composition.dart';

/// App bridge: supplies Catalog raw values to Quiz's pure policy gateway.
final quizCandidateSourceProvider = Provider<QuizCandidateSource>(
  (ref) => createQuizCandidateSource(
    ref.read(catalogCompositionProvider).rawQuizCandidateReaderPort,
  ),
);
