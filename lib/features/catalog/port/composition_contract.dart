import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_read_ports.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';

/// A framework-neutral lookup used by the Catalog internal composition root.
///
/// The application supplies this bridge from its DI runtime. Catalog's public
/// contract intentionally does not expose runtime, provider, or database
/// types.
typedef CatalogDependencyReaderPort = T Function<T>(Object dependency);

/// The public Catalog read capabilities assembled for an application scope.
final class CatalogComposition {
  const CatalogComposition({
    required this.readPorts,
    required this.catalogReaderPort,
    required this.conjugationReaderPort,
  });

  /// The complete, scope-stable Catalog read API.
  final CatalogReadPorts readPorts;

  /// Legacy capabilities retained while existing consumers migrate.
  final CatalogReaderPort catalogReaderPort;
  final ConjugationReaderPort conjugationReaderPort;
}
