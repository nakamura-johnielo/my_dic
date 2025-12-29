import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';

class FirebaseWordStatusRepository implements IRemoteWordStatusRepository {
  final IRemoteWordStatusDataSource _dataSource;

  FirebaseWordStatusRepository(this._dataSource);

  @override
  Future<WordStatus?> getWordStatusById(String userId, int id) async {
    return await _dataSource.getWordStatusById(userId, id);
  }

  @override
  Future<List<WordStatus>> getWordStatusAfter(String userId, DateTime datetime) async {
    return await _dataSource.getWordStatusAfter(userId, datetime);
  }

  @override
  Future<void> updateWordStatus(String userId, WordStatus wordStatus) async {
    await _dataSource.updateWordStatus(userId, wordStatus);
  }

  @override
  Stream<WordStatus> watchWordStatusById(String userId, int id) {
    return _dataSource.watchWordStatusById(userId, id);
  }

  @override
  Stream<List<int>> watchChangedIds(String userId) {
    return _dataSource.watchChangedIds(userId);
  }

  @override
  Future<void> updateWordStatusBatch(String userId, List<WordStatus> wordStatusList) async {
    await _dataSource.updateWordStatusBatch(userId, wordStatusList);
  }
}
