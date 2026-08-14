/// The sole business-facing import for Ranking.
library;

export 'package:my_dic/core/shared/utils/result.dart'
    show Failure, Result, Success;
export 'package:my_dic/features/catalog/port/catalog.dart'
    show CatalogId, CatalogWordRef;
export 'error/ranking_read_error.dart';
export 'gateway/ranking_catalog_gateway.dart';
export 'gateway/ranking_word_status_gateway.dart';
export 'model/ranking_account_scope.dart';
export 'model/ranking_filter.dart';
export 'model/ranking_item.dart';
export 'model/ranking_item_id.dart';
export 'model/ranking_part_of_speech.dart';
export 'query/ranking_page_query.dart';
export 'reader/ranking_page_reader_port.dart';
export 'result/ranking_page.dart';
