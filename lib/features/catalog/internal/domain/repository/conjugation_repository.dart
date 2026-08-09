import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/conjugation_search_result_item.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/esp_conjugations.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/search_result_conjugations.dart';

abstract class IConjugacionsRepository {
  Future<Result<EspConjugacions?>> getConjugacionByWordId(int id);
  Future<Result<List<SearchResultConjugacions>>> getConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  );
  Future<Result<List<ConjugacionSearchResultItem>>> searchConjugations(
    String word,
    int size,
    int currentPage,
  );
  Future<Result<bool>> hasConjByWordId(int wordId);
}
