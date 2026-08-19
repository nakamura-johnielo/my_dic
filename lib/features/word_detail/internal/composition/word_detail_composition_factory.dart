import 'package:my_dic/features/word_detail/internal/application/word_detail_reader.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// WordDetail 所有のアプリケーションサービスグラフの組み立てです。
WordDetailQueryPort createInternalWordDetailReader({
  required WordDetailCatalogGateway catalogGateway,
}) =>
    WordDetailApplicationService(catalogGateway);
