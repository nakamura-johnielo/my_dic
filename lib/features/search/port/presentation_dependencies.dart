import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reader.dart';

/// App composition supplies the Catalog-backed Search reader.
final searchReaderPortDependencyProvider = Provider<SearchReaderPort>(
  (_) => throw StateError('SearchReaderPort dependency was not supplied.'),
);
