import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class IConjugacionLocalDataSource {
  Future<EspConjugationTableData?> getConjugacionByWordId(int id);
  Future<List<EspConjugationTableData>> getConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  );

  /// Searches the union used for conjugation discovery, without consumer rules.
  Future<List<EspConjugationTableData>> searchConjugationsAcrossCatalog(
    String word,
    int size,
    int currentPage,
  );

  Future<bool> existsConjByWordId(int wordId);
  Future<String?> getSimpleMeaningById(int id);
  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds);
}
