import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/quiz/port/composition.dart';
import 'package:my_dic/integration/catalog_quiz/catalog_backed_quiz_candidate_gateway.dart';
import 'package:my_dic/integration/catalog_quiz/catalog_backed_quiz_game_gateway.dart';

final quizCandidateCatalogGatewayProvider = Provider(
  (ref) => CatalogBackedQuizCandidateGateway(
    ref.watch(catalogReadPortsProvider),
  ),
);

final quizGameCatalogGatewayProvider = Provider(
  (ref) => CatalogBackedQuizGameGateway(
    ref.watch(catalogReadPortsProvider),
  ),
);

/// App-owned Riverpod lifetime for the Quiz graph and its runtime adapters.
final quizPortsProvider = Provider<QuizPorts>(
  (ref) => createQuizPorts(
    dependencies: QuizDependencies(
      candidateCatalogGateway: ref.watch(quizCandidateCatalogGatewayProvider),
      gameCatalogGateway: ref.watch(quizGameCatalogGatewayProvider),
      database: ref.watch(databaseProvider),
      loadAssetText: rootBundle.loadString,
    ),
  ),
);
