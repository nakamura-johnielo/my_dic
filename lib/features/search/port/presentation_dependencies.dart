import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reader.dart';

/// App composition supplies the Catalog-backed Search reader.
final searchQueryPortDependencyProvider = Provider<SearchQueryPort>(
  (_) => throw StateError('SearchQueryPort dependency was not supplied.'),
);
