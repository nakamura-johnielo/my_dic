import 'package:my_dic/features/search/internal/composition/search_composition_factory.dart';
import 'package:my_dic/features/search/port/search.dart';

/// Application-owned dependencies required to assemble Search capabilities.
final class SearchDependencies {
  const SearchDependencies({required this.catalogGateway});

  final SearchCatalogGateway catalogGateway;
}

/// The complete Search capabilities supplied to an application scope.
final class SearchPorts {
  const SearchPorts({required this.reader});

  final SearchReaderPort reader;
}

/// Assembles Search's internal policy graph without framework state.
SearchPorts createSearchComposition({
  required SearchDependencies dependencies,
}) =>
    SearchPorts(
      reader: createInternalSearchReader(
        catalogGateway: dependencies.catalogGateway,
      ),
    );
