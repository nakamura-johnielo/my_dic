import 'package:my_dic/features/word_detail/internal/composition/word_detail_composition_factory.dart';
import 'package:my_dic/features/word_detail/port/composition_contract.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

export 'composition_contract.dart' show WordDetailPorts;

/// Immutable typed dependencies required to assemble WordDetail.
final class WordDetailDependencies {
  const WordDetailDependencies({required this.catalogGateway});

  final WordDetailCatalogGateway catalogGateway;
}

/// Assembles WordDetail without framework state or service location.
WordDetailPorts createWordDetailComposition({
  required WordDetailDependencies dependencies,
}) =>
    WordDetailPorts(
      reader: createInternalWordDetailReader(
        catalogGateway: dependencies.catalogGateway,
      ),
    );
