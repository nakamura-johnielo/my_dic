
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/word_status_converter.dart';

class DriftWordStatusRepository implements ILocalWordStatusRepository {
  final ILocalWordStatusDataSource _dataSource;

  DriftWordStatusRepository(this._dataSource);

  @override
  Future<WordStatus> getWordStatusById(int id) async {
    final tableData = await _dataSource.getWordStatusById(id);
    return WordStatusConverter.toEntity(tableData, id);
  }

  @override
  Future<List<WordStatus>> getWordStatusAfter(DateTime datetime) async {
    final tableDataList = await _dataSource.getWordStatusAfter(datetime);
    return WordStatusConverter.toEntityList(tableDataList);
  }

  @override
  Future<void> updateWordStatus(WordStatus wordStatus) async {
    final tableData = WordStatusConverter.toTableData(wordStatus);
    await _dataSource.updateWordStatus(tableData);
  }

  @override
  Stream<WordStatus> watchWordStatusById(int id) {
    return _dataSource.watchWordStatusById(id).map((tableData) => 
      WordStatusConverter.toEntity(tableData, id));
  }

  @override
  Stream<List<int>> watchChangedIds(DateTime datetime) {
    return _dataSource.watchChangedIds(datetime);
  }
}
