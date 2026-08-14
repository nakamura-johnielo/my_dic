/// The sole business-facing import for Search contracts.
library;

export 'package:my_dic/core/shared/utils/result.dart'
    show Failure, Result, Success;
export 'error/search_catalog_gateway_error.dart';
export 'error/search_issue.dart';
export 'error/search_read_error.dart';
export 'gateway/search_catalog_gateway.dart';
export 'model/search_conjugation_match.dart';
export 'model/search_direction.dart';
export 'model/search_result_item.dart';
export 'query/search_catalog_query.dart';
export 'query/search_query.dart';
export 'reader/search_reader_port.dart';
export 'result/search_catalog_page.dart';
export 'result/search_result_page.dart';
