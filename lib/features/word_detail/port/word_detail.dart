/// The sole business-facing import for WordDetail contracts.
library;

export 'package:my_dic/core/shared/utils/result.dart'
    show Failure, Result, Success;
export 'package:my_dic/features/catalog/port/catalog.dart'
    show CatalogId, CatalogWordRef;
export 'error/word_detail_read_error.dart';
export 'gateway/word_detail_catalog_gateway.dart';
export 'model/word_detail_conjugation.dart';
export 'model/word_detail_content_block.dart';
export 'model/word_detail_data.dart';
export 'model/word_detail_entry.dart';
export 'model/word_detail_issue.dart';
export 'presentation_input.dart';
export 'reader/word_detail_reader_port.dart';
export 'result/word_detail_result.dart';
export 'route.dart';
export 'word_detail_query.dart';
