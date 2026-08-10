import 'package:my_dic/features/catalog/port/raw_quiz_candidate_reader.dart';
import 'package:my_dic/features/quiz/internal/candidate_search/catalog_raw_quiz_candidate_source.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';

export 'game_loader.dart';
export 'model/quiz_game_data.dart';
export 'model/quiz_game_load_result.dart';
export 'model/quiz_game_load_source.dart';
export 'model/quiz_game_query.dart';

/// Builds Quiz policy from provider-neutral Catalog raw capabilities.
QuizCandidateSource createQuizCandidateSource(
        CatalogRawQuizCandidateReader catalog) =>
    CatalogRawQuizCandidateSource(catalog);
