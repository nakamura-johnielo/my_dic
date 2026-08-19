import 'package:my_dic/features/word_detail/internal/composition/word_detail_composition_factory.dart';
import 'package:my_dic/features/word_detail/port/composition_contract.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

export 'composition_contract.dart' show WordDetailPorts;

/// WordDetail の組み立てに必要な不変の型付き依存関係です。
final class WordDetailDependencies {
  const WordDetailDependencies({required this.catalogGateway});

  final WordDetailCatalogGateway catalogGateway;
}

/// フレームワーク状態やサービスロケーションなしで WordDetail を組み立てます。
WordDetailPorts createWordDetailComposition({
  required WordDetailDependencies dependencies,
}) =>
    WordDetailPorts(
      reader: createInternalWordDetailReader(
        catalogGateway: dependencies.catalogGateway,
      ),
    );
