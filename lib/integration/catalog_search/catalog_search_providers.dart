import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/features/search/port/composition.dart';
import 'package:my_dic/features/search/port/reader.dart';
import 'package:my_dic/integration/catalog_search/catalog_backed_search_gateway.dart';

/// App wiring only; value and error conversion lives in the pure adapter.
final searchReaderPortProvider = Provider<SearchReaderPort>(
  (ref) => createSearchComposition(
    CatalogBackedSearchGateway(ref.read(catalogReadPortsProvider)),
  ),
);
