import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reader.dart';

/// App composition supplies the Catalog-backed Search reader.
final searchReaderDependencyProvider = Provider<SearchReader>(
  (_) => throw StateError('SearchReader dependency was not supplied.'),
);
