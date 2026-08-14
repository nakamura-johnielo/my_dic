import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';

class ConjugationDriftDataSource implements ConjugationDataSource {
  ConjugationDriftDataSource(this._conjugationDao);
  final ConjugationDao _conjugationDao;

  @override
  Future<bool> existsConjugationByWordId(int wordId) =>
      _conjugationDao.exists(wordId);
  @override
  Future<EspConjugationTableData?> getConjugationByWordId(int id) =>
      _conjugationDao.getConjugationById(id);
}
