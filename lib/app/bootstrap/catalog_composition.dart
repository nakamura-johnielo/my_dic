import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/composition.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';

final catalogCompositionProvider = Provider<CatalogComposition>((ref) {
  return createCatalogComposition(<T>(dependency) {
    return ref.read(dependency as ProviderListenable<T>);
  });
});

/// App-facing provider retained for existing Catalog reader consumers.
final catalogReaderPortProvider = Provider<CatalogReaderPort>(
  (ref) => ref.read(catalogCompositionProvider).catalogReaderPort,
);

/// App-facing provider retained for existing conjugation reader consumers.
final conjugationReaderPortProvider = Provider<ConjugationReaderPort>(
  (ref) => ref.read(catalogCompositionProvider).conjugationReaderPort,
);
