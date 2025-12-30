import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';

class DriftWordStatusRepository implements ILocalWordStatusRepository {
  final ILocalWordStatusDataSource _dataSource;

  DriftWordStatusRepository(this._dataSource);

  @override
  Future<WordStatus> getWordStatusById(int id) async {
    return await _dataSource.getWordStatusById(id);
  }

  @override
  Future<List<WordStatus>> getWordStatusAfter(DateTime datetime) async {
    return await _dataSource.getWordStatusAfter(datetime);
  }

  @override
  Future<void> updateWordStatus(WordStatus wordStatus) async {
    await _dataSource.updateWordStatus(wordStatus);
  }

  @override
  Stream<WordStatus> watchWordStatusById(int id) {
    return _dataSource.watchWordStatusById(id);
  }

  @override
  Stream<List<int>> watchChangedIds(DateTime datetime) {
    return _dataSource.watchChangedIds(datetime);
  }
}
