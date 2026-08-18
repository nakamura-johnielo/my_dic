import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/word_status/internal/domain/model/word_status_record.dart';
import 'package:my_dic/features/word_status/internal/domain/word_status_repository_error.dart';

import 'esp_jpn_word_status_local_data_source.dart';

class EspJpnWordStatusLocalStore implements EspJpnWordStatusLocalDataSource {
  final EspJpnWordStatusDao _dao;
  EspJpnWordStatusLocalStore(this._dao);

  @override
  Future<WordStatusRecord?> getWordStatusRecordById(
      int id, String accountId) async {
    final row = await _dao.getStatusById(id, accountId);
    return row == null ? null : _toRecord(row);
  }

  @override
  Future<List<WordStatusRecord>> getWordStatusRecordsByIds(
      Iterable<int> ids, String accountId) async =>
      (await _dao.getStatusesByIds(ids, accountId))
          .map(_toRecord)
          .toList(growable: false);

  @override
  Stream<WordStatusRecord?> watchWordStatusRecordById(
          int id, String accountId) =>
      _dao.watchWordStatus(id, accountId).map(
            (row) => row == null ? null : _toRecord(row),
          );

  WordStatusRecord _toRecord(EspJpnWordStatusTableData row) {
    final updatedAt = DateTime.tryParse(row.editAt);
    if (updatedAt == null) throw const WordStatusRecordCorruptionError();
    return WordStatusRecord(
      wordId: row.wordId,
      isLearned: row.isLearned == 1,
      isBookmarked: row.isBookmarked == 1,
      hasNote: row.hasNote == 1,
      updatedAt: updatedAt.toUtc(),
    );
  }

  @override
  Future<EspJpnWordStatusTableData?> getWordStatusById(
      int id, String accountId) async {
    final data = await _dao.getStatusById(id, accountId);
    return data;
  }

  @override
  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(
      DateTime datetime, String accountId) async {
    final list = await _dao.getWordStatusAfter(datetime, accountId);
    return list;
  }

  @override
  Future<EspJpnWordStatusTableData> updateWordStatus(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
    String accountId,
  ) async {
    return _dao.applyStatusPatch(
      wordId,
      isLearned,
      isBookmarked,
      hasNote,
      editAt,
      accountId,
    );
  }

  @override
  Stream<EspJpnWordStatusTableData?> watchWordStatusById(
      int id, String accountId) {
    return _dao.watchWordStatus(id, accountId);
  }

  @override
  Stream<List<int>> watchChangedIds(DateTime datetime, String accountId) {
    return _dao.watchChangedWordIdsWithFilter(datetime, accountId);
  }

  @override
  Future<void> applyRemoteFields(
    int wordId, {
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  }) {
    return _dao.applyRemoteFields(
      wordId,
      isLearned: isLearned,
      isBookmarked: isBookmarked,
      hasNote: hasNote,
      editAt: editAt,
      accountId: accountId,
      remoteRevision: remoteRevision,
      lastMutationId: lastMutationId,
    );
  }

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      _dao.transaction(action);

  @override
  Future<bool> acknowledgeRemoteMutation({
    required int wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) =>
      _dao.acknowledgeRemoteMutation(
        wordId: wordId,
        accountId: accountId,
        localRevision: localRevision,
        remoteRevision: remoteRevision,
        lastMutationId: lastMutationId,
      );

  @override
  Future<void> deleteRow(int id, String accountId) =>
      _dao.deleteRow(id, accountId);
}
