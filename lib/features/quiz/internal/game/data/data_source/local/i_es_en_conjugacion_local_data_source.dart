import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class IEsEnConjugacionLocalDataSource {
  Future<EsEnConjugacionTableData?> getEnglishConjById(int id);
}
