import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/catalog/port/composition.dart';

final catalogCompositionProvider = Provider<CatalogComposition>((ref) {
  return createCatalogComposition(<T>(dependency) {
    return ref.read(dependency as ProviderListenable<T>);
  });
});

final catalogReadPortsProvider = Provider<CatalogReadPorts>(
  (ref) => ref.watch(catalogCompositionProvider).readPorts,
);

/// App-facing provider retained for existing Catalog reader consumers.
final catalogQueryPortProvider = Provider<CatalogQueryPort>(
  (ref) => ref.read(catalogCompositionProvider).catalogQueryPort,
);

/// App-facing provider retained for existing conjugation reader consumers.
final conjugationQueryPortProvider = Provider<ConjugationQueryPort>(
  (ref) => ref.read(catalogCompositionProvider).conjugationQueryPort,
);
