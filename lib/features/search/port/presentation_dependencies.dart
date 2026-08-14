import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/search/port/search.dart';

/// App composition supplies the Catalog-backed Search reader.
final searchReaderPortDependencyProvider = Provider<SearchReaderPort>(
  (_) => throw StateError('SearchReaderPort dependency was not supplied.'),
);
