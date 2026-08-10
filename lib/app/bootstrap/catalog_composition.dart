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
final catalogReaderProvider = Provider<CatalogReader>(
  (ref) => ref.read(catalogCompositionProvider).catalogReader,
);

/// App-facing provider retained for existing conjugation reader consumers.
final conjugationReaderProvider = Provider<ConjugationReader>(
  (ref) => ref.read(catalogCompositionProvider).conjugationReader,
);
