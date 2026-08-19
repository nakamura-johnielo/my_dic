import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/catalog_composition.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';
import 'package:my_dic/integration/catalog_word_detail/catalog_backed_word_detail_gateway.dart';

/// 現在のアプリケーションスコープに必要な、Catalogを基盤とするゲートウェイ。
final catalogBackedWordDetailGatewayProvider =
    Provider<WordDetailCatalogGateway>(
  (ref) => CatalogBackedWordDetailGateway(
    ref.watch(catalogQueryPortsProvider),
  ),
);
