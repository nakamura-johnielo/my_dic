import 'package:my_dic/features/word_detail/internal/application/word_detail_reader.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// WordDetail-owned assembly of its application service graph.
WordDetailReaderPort createInternalWordDetailReader({
  required WordDetailCatalogGateway catalogGateway,
}) =>
    WordDetailApplicationService(catalogGateway);
