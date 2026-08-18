import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import 'package:my_dic/features/word_detail/port/model/word_detail_conjugation.dart';
import 'package:my_dic/features/word_detail/port/model/word_detail_data.dart';

/// Catalog capabilities required by WordDetail, expressed in consumer terms.
abstract interface class WordDetailCatalogGateway {
  /// Reads the required primary dictionary aggregate.
  Future<Result<WordDetailDictionary>> readDictionary(CatalogWordRef word);

  /// Reads optional Spanish conjugation data.
  ///
  /// A successful `null` value means that the Catalog has no conjugation for
  /// [word]. Provider failures remain independent from the primary read.
  Future<Result<WordDetailConjugation?>> readConjugation(
    CatalogWordRef word,
  );
}
