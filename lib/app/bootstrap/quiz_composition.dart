import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/assets/quiz_game_assets.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/dao/es_en_conjugacion_dao.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/quiz_game_drift_english_reader.dart';
import 'package:my_dic/features/quiz/port/composition.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';
import 'package:my_dic/integration/catalog_quiz/catalog_backed_quiz_candidate_gateway.dart';
import 'package:my_dic/integration/catalog_quiz/catalog_backed_quiz_game_gateway.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';

final quizCandidateCatalogGatewayProvider =
    Provider<QuizCandidateCatalogGateway>(
  (ref) =>
      CatalogBackedQuizCandidateGateway(ref.read(catalogReadPortsProvider)),
);

final quizGameCatalogGatewayProvider = Provider<QuizGameCatalogGateway>(
  (ref) => CatalogBackedQuizGameGateway(ref.read(catalogReadPortsProvider)),
);

/// App-owned Riverpod lifetime for the Quiz graph and its runtime adapters.
final quizPortsProvider = Provider<QuizPorts>((ref) {
  final dao = EsEnConjugacionDao(ref.watch(databaseProvider));
  return createQuizPorts(<T>(dependency) {
    switch (dependency) {
      case QuizDependency.candidateCatalogGateway:
        return ref.watch(quizCandidateCatalogGatewayProvider) as T;
      case QuizDependency.gameCatalogGateway:
        return ref.watch(quizGameCatalogGatewayProvider) as T;
      case QuizDependency.englishReader:
        return QuizGameDriftEnglishReader(dao) as T;
      case QuizDependency.assetReader:
        return QuizGameAssets() as T;
    }
  });
});
