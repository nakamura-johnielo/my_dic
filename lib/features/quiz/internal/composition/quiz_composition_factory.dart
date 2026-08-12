import 'package:my_dic/features/quiz/internal/application/candidate_search/gateway_quiz_candidate_source.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_application_service.dart';
import 'package:my_dic/features/quiz/port/composition.dart';

/// Quiz-owned assembly of application policy and owner-side infrastructure
/// seams. Runtime construction remains app-bootstrap owned.
QuizPorts createInternalQuizPorts(QuizDependencyReader read) => QuizPorts(
      candidateReader: GatewayQuizCandidateSource(
          read(QuizDependency.candidateCatalogGateway)),
      gameReader: QuizGameApplicationService(
        catalogGateway: read(QuizDependency.gameCatalogGateway),
        englishReader: read(QuizDependency.englishReader),
        assetReader: read(QuizDependency.assetReader),
      ),
    );
