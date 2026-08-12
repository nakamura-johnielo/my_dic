import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';
import 'package:my_dic/features/quiz/port/composition.dart';
import 'package:my_dic/integration/catalog_quiz/catalog_backed_quiz_gateway.dart';

/// App wiring only; value and error conversion lives in the pure adapter.
final quizCandidateSourceProvider = Provider<QuizCandidateSource>(
  (ref) => createQuizCandidateSource(
    CatalogBackedQuizGateway(ref.read(catalogReadPortsProvider)),
  ),
);
