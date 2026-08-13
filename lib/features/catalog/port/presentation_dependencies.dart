import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_read_ports.dart';
import 'catalog_reader.dart';
import 'conjugation_reader.dart';

/// App routing/composition supplies Catalog capabilities to feature UI.
final catalogReadPortsDependencyProvider = Provider<CatalogReadPorts>(
  (_) => throw StateError('CatalogReadPorts dependency was not supplied.'),
);

//todo remove
/// Legacy dependencies retained while existing presentation consumers migrate.
final catalogQueryPortDependencyProvider = Provider<CatalogQueryPort>(
  (_) => throw StateError('CatalogQueryPort dependency was not supplied.'),
);

final conjugationQueryPortDependencyProvider = Provider<ConjugationQueryPort>(
  (_) => throw StateError('ConjugationQueryPort dependency was not supplied.'),
);
