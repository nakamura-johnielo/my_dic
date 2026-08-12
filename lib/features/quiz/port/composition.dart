import 'package:my_dic/features/quiz/internal/candidate_search/quiz_candidate_source.dart';
import 'package:my_dic/features/quiz/port/catalog_gateway.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';

export 'game_loader.dart';
export 'model/quiz_game_data.dart';
export 'model/quiz_game_load_result.dart';
export 'model/quiz_game_load_source.dart';
export 'model/quiz_game_query.dart';

/// Builds Quiz policy from its provider-neutral required Catalog boundary.
QuizCandidateSource createQuizCandidateSource(QuizCatalogGateway catalog) =>
    GatewayQuizCandidateSource(catalog);
