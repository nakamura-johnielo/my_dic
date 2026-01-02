import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/dtos/wordStatusEntity.dart';

class FirebaseWordStatusRepository implements IRemoteWordStatusRepository {
  final IRemoteWordStatusDataSource _dataSource;

  FirebaseWordStatusRepository(this._dataSource);

  @override
  Future<WordStatus?> getWordStatusById(String userId, int id) async {
    final dto = await _dataSource.getWordStatusById(userId, id);
    return dto?.toEntity();
  }

  @override
  Future<List<WordStatus>> getWordStatusAfter(String userId, DateTime datetime) async {
    final dtoList = await _dataSource.getWordStatusAfter(userId, datetime);
    return dtoList.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> updateWordStatus(String userId, WordStatus wordStatus) async {
    final dto = WordStatusDTO.fromAppEntity(wordStatus);
    await _dataSource.updateWordStatus(userId, dto);
  }

  @override
  Stream<WordStatus> watchWordStatusById(String userId, int id) {
    return _dataSource.watchWordStatusById(userId, id).map((dto) => dto.toEntity());
  }

  @override
  Stream<List<int>> watchChangedIds(String userId) {
    return _dataSource.watchChangedIds(userId);
  }

  @override
  Future<void> updateWordStatusBatch(String userId, List<WordStatus> wordStatusList) async {
    final dtoList = wordStatusList.map((w) => WordStatusDTO.fromAppEntity(w)).toList();
    await _dataSource.updateWordStatusBatch(userId, dtoList);
  }
}
