import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_reader.dart';
import 'conjugation_reader.dart';

/// App routing/composition supplies Catalog capabilities to feature UI.
final catalogReaderPortDependencyProvider = Provider<CatalogReaderPort>(
  (_) => throw StateError('CatalogReaderPort dependency was not supplied.'),
);

final conjugationReaderPortDependencyProvider = Provider<ConjugationReaderPort>(
  (_) => throw StateError('ConjugationReaderPort dependency was not supplied.'),
);
