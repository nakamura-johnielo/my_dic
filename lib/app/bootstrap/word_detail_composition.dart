import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/word_detail/port/composition.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';
import 'package:my_dic/integration/catalog_word_detail/catalog_word_detail_providers.dart';

/// Completed WordDetail capabilities for the application scope.
final wordDetailPortsProvider = Provider<WordDetailPorts>(
  (ref) => createWordDetailComposition(
    dependencies: WordDetailDependencies(
      catalogGateway: ref.watch(catalogBackedWordDetailGatewayProvider),
    ),
  ),
);

final wordDetailReaderPortProvider = Provider<WordDetailReaderPort>(
  (ref) => ref.watch(wordDetailPortsProvider).reader,
);
