import 'package:my_dic/core/infrastructure/database/drift/daos/es_en_conjugacion_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/quiz/data/data_source/local/i_es_en_conjugacion_local_data_source.dart';

class EsEnConjugacionDriftDataSource implements IEsEnConjugacionLocalDataSource {
  final EsEnConjugacionDao _dao;
  EsEnConjugacionDriftDataSource(this._dao);

  @override
  Future<EsEnConjugacionTableData?> getEnglishConjById(int id) async {
    return await _dao.getEnglishConjById(id);
  }
}
