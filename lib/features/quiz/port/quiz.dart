/// Quiz の唯一の業務用インポート面。
library;

export 'package:my_dic/core/shared/errors/app_error.dart' show AppError;
export 'package:my_dic/core/shared/utils/result.dart'
    show Result, Success, Failure;
export 'package:my_dic/features/catalog/port/catalog.dart'
    show CatalogId, CatalogWordRef;
export 'error/quiz_candidate_issue.dart';
export 'error/quiz_catalog_gateway_error.dart';
export 'error/quiz_game_load_error.dart';
export 'error/quiz_game_infrastructure_error.dart';
export 'gateway/quiz_candidate_catalog_gateway.dart';
export 'gateway/quiz_game_catalog_gateway.dart';
export 'model/quiz_conjugation.dart';
export 'presentation_input.dart';
export 'query/quiz_candidate_query.dart';
export 'query/quiz_game_query.dart';
export 'query/quiz_candidate_reader_port.dart';
export 'query/quiz_game_reader_port.dart';
export 'result/quiz_candidate_page.dart';
export 'result/quiz_game_load_outcome.dart';
export 'route.dart';
