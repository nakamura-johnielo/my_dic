import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dataSource/my_word_status_local_store.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/mapper/my_word_infrastructure_error_mapper.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_status_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/update_my_word_status_record.dart';
import 'package:uuid/uuid.dart';

final class DriftMyWordStatusRepository implements IMyWordStatusRepository {
  final IMyWordStatusLocalDataSource _localStore;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;

  DriftMyWordStatusRepository(
    this._localStore,
    this._outboxWriter, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<void>> updateStatus(
    UpdateMyWordStatusInputData input,
  ) async {
    try {
      final scope = input.userId ?? guestAccountScope;
      await _localStore.runInTransaction(() async {
        final row = await _localStore.applyStatusPatch(
          input.wordId,
          _toNullableInt(input.isLearned),
          _toNullableInt(input.isBookmarked),
          _toNullableInt(input.hasNote),
          input.editAt.toIso8601String(),
          scope,
        );
        if (input.userId != null) {
          final fieldMask = <String>[];
          final payload = <String, Object?>{};
          if (input.isLearned case SetValue(value: final value)) {
            fieldMask.add('isLearned');
            payload['isLearned'] = value;
          }
          if (input.isBookmarked case SetValue(value: final value)) {
            fieldMask.add('isBookmarked');
            payload['isBookmarked'] = value;
          }
          if (input.hasNote case SetValue(value: final value)) {
            fieldMask.add('hasNote');
            payload['hasNote'] = value;
          }
          if (fieldMask.isNotEmpty) {
            await _outboxWriter.enqueue(SyncMutation(
              mutationId: _uuid.v4(),
              accountId: input.userId!,
              dataset: SyncDataset.myWordStatus,
              entityId: input.wordId,
              operation: SyncMutationOperation.patch,
              payload: payload,
              fieldMask: fieldMask,
              localRevision: row.localRevision,
              clientUpdatedAt: input.editAt.toUtc(),
            ));
          }
        }
      });
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(MyWordInfrastructureErrorMapper.database(
        e,
        s,
        message: 'Failed to update my word status.',
      ));
    }
  }

  @override
  Stream<MyWordStatus> watchStatus(String wordId, {required String accountId}) {
    return _localStore.watchWordStatus(wordId, accountId).map((data) {
      if (data == null) {
        return MyWordStatus(
          wordId: wordId,
          isLearned: false,
          isBookmarked: false,
        );
      }
      AppLogger.print(
        'my word status ${data.myWordId}: '
        'learned=${data.isLearned}, bookmarked=${data.isBookmarked}',
      );
      return MyWordStatus(
        wordId: data.myWordId,
        isLearned: data.isLearned == 1,
        isBookmarked: data.isBookmarked == 1,
      );
    });
  }

  int? _toNullableInt(FieldUpdate<bool> update) => switch (update) {
        SetValue(value: final value) => value ? 1 : 0,
        Unchanged() => null,
      };
}
