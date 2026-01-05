import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as drift;

import 'i_jpn_esp_word_data_source.dart';

class JpnEspDriftWordDataSource implements IJpnEspWordLocalDataSource {
  final JpnEspWordDao _dao;
  JpnEspDriftWordDataSource(this._dao);

  @override
  Future<List<drift.JpnEspWordTableData>> getWordsByWord(String word, int size, int currentPage) async {
    final rows = await _dao.getWordsByWord(word, size, currentPage);
    
    return rows;
  }

  @override
  Future<void> updateStatus(UpdateStatusRepositoryInputData input) async {
    final data = drift.EspJpnWordStatusTableData(
      wordId: input.wordId,
      isLearned: input.status.contains(FeatureTag.isLearned) ? 1 : 0,
      isBookmarked: input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
      hasNote: input.status.contains(FeatureTag.hasNote) ? 1 : 0,
      editAt: input.editAt,
    );
    // Repository constructed the table data but didn't persist it; mirror that behaviour.
    return;
  }
}
