import 'package:my_dic/features/catalog/internal/composition/catalog_composition_factory.dart';
import 'package:my_dic/features/catalog/port/composition_contract.dart';

export 'composition_contract.dart';

/// Creates Catalog's public read capabilities from an application dependency
/// bridge.
///
/// The implementation lives in Catalog internal composition; this facade keeps
/// callers independent from Riverpod and Drift.
CatalogComposition createCatalogComposition(CatalogDependencyQueryPort read) =>
    createInternalCatalogComposition(read);
