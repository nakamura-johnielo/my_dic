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
final catalogReaderPortDependencyProvider = Provider<CatalogReaderPort>(
  (_) => throw StateError('CatalogReaderPort dependency was not supplied.'),
);

final conjugationReaderPortDependencyProvider = Provider<ConjugationReaderPort>(
  (_) => throw StateError('ConjugationReaderPort dependency was not supplied.'),
);
