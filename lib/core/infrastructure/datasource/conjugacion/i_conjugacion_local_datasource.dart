import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class IConjugacionLocalDataSource {
  Future<EspConjugationTableData?> getConjugacionByWordId(int id);
  Future<List<EspConjugationTableData>> getConjugacionByWordWithPage(
      String word, int size, int currentPage);
  Future<List<EspConjugationTableData>> getQuizConjugacionByWordWithPage(
      String word, int size, int currentPage);
}
