import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/quiz/internal/application/candidate_search/quiz_candidate_query_service.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_application_service.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/assets/quiz_game_assets.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/dao/es_en_conjugacion_dao.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/quiz_game_drift_english_reader.dart';
import 'package:my_dic/features/quiz/port/composition_contract.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

/// Quiz-owned assembly of application policy and owner-side infrastructure.
QuizPorts createInternalQuizPorts({
  required QuizCandidateCatalogGateway candidateCatalogGateway,
  required QuizGameCatalogGateway gameCatalogGateway,
  required DatabaseProvider database,
  required Future<String> Function(String assetPath) loadAssetText,
}) {
  final englishReader = QuizGameDriftEnglishReader(
    EsEnConjugacionDao(database),
  );
  final assetReader = QuizGameAssets.loadingText(loadAssetText);

  return QuizPorts(
    candidateReader: QuizCandidateQueryService(candidateCatalogGateway),
    gameReader: QuizGameApplicationService(
      catalogGateway: gameCatalogGateway,
      englishReader: englishReader,
      assetReader: assetReader,
    ),
  );
}
