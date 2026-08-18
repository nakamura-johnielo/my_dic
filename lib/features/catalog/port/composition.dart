import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/composition/catalog_composition_factory.dart';
import 'package:my_dic/features/catalog/port/catalog_read_ports.dart';

/// Application-owned services required to assemble Catalog capabilities.
final class CatalogDependencies {
  const CatalogDependencies({required this.database});

  final DatabaseProvider database;
}

/// Assembles Catalog's public read capabilities without framework state.
CatalogQueryPorts createCatalogComposition({
  required CatalogDependencies dependencies,
}) =>
    createInternalCatalogComposition(database: dependencies.database);
