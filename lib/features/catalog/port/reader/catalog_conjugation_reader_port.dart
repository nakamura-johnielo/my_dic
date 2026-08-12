import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

abstract interface class CatalogConjugationReaderPort {
  Future<Result<CatalogConjugation?>> readConjugation(CatalogWordRef word);

  Future<Result<bool>> hasConjugation(CatalogWordRef word);
}
