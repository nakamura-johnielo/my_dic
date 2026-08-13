import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

/// Reads optional conjugation data supported by a Catalog dataset.
abstract interface class ConjugationQueryPort {
  Future<Result<CatalogConjugation?>> getConjugation(CatalogWordRef word);

  Future<Result<bool>> hasConjugation(CatalogWordRef word);
}
