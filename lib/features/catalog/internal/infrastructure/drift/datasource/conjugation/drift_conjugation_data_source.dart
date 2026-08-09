import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';

class ConjugacionDriftDataSource implements IConjugacionLocalDataSource {
  ConjugacionDriftDataSource(this._conjugacionDao);
  final ConjugationDao _conjugacionDao;

  @override
  Future<String?> getSimpleMeaningById(int id) =>
      _conjugacionDao.getMeaningById(id);
  @override
  Future<bool> existsConjByWordId(int wordId) => _conjugacionDao.exists(wordId);
  @override
  Future<EspConjugationTableData?> getConjugacionByWordId(int id) =>
      _conjugacionDao.getConjugationById(id);
  @override
  Future<List<EspConjugationTableData>> getConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  ) =>
      _conjugacionDao.getConjugationByWordWithPage(word, size, currentPage);
  @override
  Future<List<EspConjugationTableData>> searchConjugationsAcrossCatalog(
    String word,
    int size,
    int currentPage,
  ) =>
      _conjugacionDao.getConjugationInAllTableByWordWithPage(
        word,
        size,
        currentPage,
      );
  @override
  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds) =>
      _conjugacionDao.getMeaningsByWordIds(wordIds);
}
