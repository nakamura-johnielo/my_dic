import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract interface class ConjugationDataSource {
  Future<EspConjugationTableData?> getConjugationByWordId(int id);

  Future<bool> existsConjugationByWordId(int wordId);
}
