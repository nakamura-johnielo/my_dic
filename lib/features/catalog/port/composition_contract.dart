import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/raw_quiz_candidate_reader.dart';
import 'package:my_dic/features/catalog/port/raw_search_reader.dart';

/// A framework-neutral lookup used by the Catalog internal composition root.
///
/// The application supplies this bridge from its DI runtime. Catalog's public
/// contract intentionally does not expose runtime, provider, or database
/// types.
typedef CatalogDependencyReaderPort = T Function<T>(Object dependency);

/// The public Catalog read capabilities assembled for an application scope.
final class CatalogComposition {
  const CatalogComposition({
    required this.catalogReaderPort,
    required this.conjugationReaderPort,
    required this.rawSearchReaderPort,
    required this.rawQuizCandidateReaderPort,
  });

  final CatalogReaderPort catalogReaderPort;
  final ConjugationReaderPort conjugationReaderPort;
  final CatalogRawSearchReaderPort rawSearchReaderPort;
  final CatalogRawQuizCandidateReaderPort rawQuizCandidateReaderPort;
}
