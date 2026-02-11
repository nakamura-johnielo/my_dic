import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/conjugation_dao.dart';

import 'i_conjugacion_local_datasource.dart';

class ConjugacionDriftDataSource implements IConjugacionLocalDataSource {
  final ConjugationDao _conjugacionDao;
  ConjugacionDriftDataSource(this._conjugacionDao);
     @override
  Future<String?> getSimpleMeaningById(int id) async {
    final meaning = await _conjugacionDao.getMeaningById(id);
    return meaning;
  }

   @override
   Future<bool> existsConjByWordId(int wordId) async {
    final exists = await _conjugacionDao.exists(wordId);
    return exists;
   }
   
  @override
  Future<EspConjugationTableData?> getConjugacionByWordId(int id) async {
    return await _conjugacionDao.getConjugationById(id);
  }

  @override
  Future<List<EspConjugationTableData>> getConjugacionByWordWithPage(
      String word, int size, int currentPage) async {
    final conjugaciones = await _conjugacionDao.getConjugationByWordWithPage(
        word, size, currentPage);
    return conjugaciones;
  }

  @override
  Future<List<EspConjugationTableData>> getQuizConjugacionByWordWithPage(
      String word, int size, int currentPage) async {
    final conjugaciones = await _conjugacionDao
        .getConjugationInAllTableByWordWithPage(word, size, currentPage);
    return conjugaciones;
  }

  @override
  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds) async {
    return await _conjugacionDao.getMeaningsByWordIds(wordIds);
  }
}
