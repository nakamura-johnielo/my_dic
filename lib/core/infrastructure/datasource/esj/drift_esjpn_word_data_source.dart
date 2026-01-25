import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'i_esj_word_data_source.dart';

class DriftEspJpnWordDataSource implements IEsjWordLocalDataSource {
  final EspJpnWordDao _dao;
  final EspJpnWordStatusDao _statusDao;
  DriftEspJpnWordDataSource(this._dao, this._statusDao);

  @override
  Future<List<EspJpnWordTableData>> getWordsByWord(String word) async {
    final words = await _dao.getWordsByWord(word);

    return words;
  }

  // @override
  // Future<void> updateStatus(UpdateStatusRepositoryInputData input) async {
  //   if (await _statusDao.exist(input.wordId)) {
  //     await _statusDao.updateStatus(
  //       input.wordId,
  //       input.status.contains(FeatureTag.isLearned) ? 1 : 0,
  //       input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
  //       input.status.contains(FeatureTag.hasNote) ? 1 : 0,
  //       input.editAt,
  //     );
  //   } else {
  //     final data = EspJpnWordStatusTableData(
  //       wordId: input.wordId,
  //       isLearned: input.status.contains(FeatureTag.isLearned) ? 1 : 0,
  //       isBookmarked: input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
  //       hasNote: input.status.contains(FeatureTag.hasNote) ? 1 : 0,
  //       editAt: input.editAt,
  //     );
  //     await _statusDao.insertStatus(data);
  //   }
  // }

  @override
  Future<List<EspJpnWordTableData>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz) async {
    final words = await _dao.getWordsByWordByPage(word, size, currentPage);

    return words;
  }

  @override
  Future<List<EspJpnWordTableData>> getQuizWordsByWordByPage(
      String word, int size, int currentPage) async {
    final words = await _dao.getWordsByWordByPage(word, size, currentPage);

    return words;
  }
}
