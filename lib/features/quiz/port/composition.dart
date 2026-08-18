import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/quiz/internal/composition/quiz_composition_factory.dart';
import 'package:my_dic/features/quiz/port/composition_contract.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

export 'composition_contract.dart';

/// Loads the unparsed text of a bundled Quiz asset.
typedef QuizAssetTextLoader = Future<String> Function(String assetPath);

/// Application-owned services required to assemble Quiz capabilities.
final class QuizDependencies {
  const QuizDependencies({
    required this.candidateCatalogGateway,
    required this.gameCatalogGateway,
    required this.database,
    required this.loadAssetText,
  });

  final QuizCandidateCatalogGateway candidateCatalogGateway;
  final QuizGameCatalogGateway gameCatalogGateway;
  final DatabaseProvider database;
  final QuizAssetTextLoader loadAssetText;
}

/// Assembles Quiz's internal policy graph from application-owned inputs.
QuizPorts createQuizPorts({required QuizDependencies dependencies}) =>
    createInternalQuizPorts(
      candidateCatalogGateway: dependencies.candidateCatalogGateway,
      gameCatalogGateway: dependencies.gameCatalogGateway,
      database: dependencies.database,
      loadAssetText: dependencies.loadAssetText,
    );
