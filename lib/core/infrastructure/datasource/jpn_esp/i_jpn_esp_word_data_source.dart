import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';

abstract class IJpnEspWordLocalDataSource {
  Future<List<JpnEspWordTableData>> getWordsByWord(String word, int size, int currentPage);
  Future<void> updateStatus(UpdateStatusRepositoryInputData input);
}
