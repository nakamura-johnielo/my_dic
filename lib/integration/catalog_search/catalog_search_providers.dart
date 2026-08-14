import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/features/search/port/composition.dart';
import 'package:my_dic/features/search/port/search.dart';
import 'package:my_dic/integration/catalog_search/catalog_backed_search_gateway.dart';

/// Completed Search capabilities for the application scope.
final searchPortsProvider = Provider<SearchPorts>(
  (ref) => createSearchComposition(
    dependencies: SearchDependencies(
      catalogGateway: CatalogBackedSearchGateway(
        ref.watch(catalogReadPortsProvider),
      ),
    ),
  ),
);

/// Focused Search reader supplied to presentation and other consumers.
final searchReaderPortProvider = Provider<SearchReaderPort>(
  (ref) => ref.watch(searchPortsProvider).reader,
);
