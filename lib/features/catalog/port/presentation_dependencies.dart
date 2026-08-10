import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_reader.dart';
import 'conjugation_reader.dart';

/// App routing/composition supplies Catalog capabilities to feature UI.
final catalogReaderDependencyProvider = Provider<CatalogReader>(
  (_) => throw StateError('CatalogReader dependency was not supplied.'),
);

final conjugationReaderDependencyProvider = Provider<ConjugationReader>(
  (_) => throw StateError('ConjugationReader dependency was not supplied.'),
);
