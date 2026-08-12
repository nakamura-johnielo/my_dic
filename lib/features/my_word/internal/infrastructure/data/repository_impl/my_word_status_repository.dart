import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/i_my_word_status_local_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/mapper/my_word_infrastructure_error_mapper.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/internal/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/inputData/my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:uuid/uuid.dart';

class MyWordStatusRepository implements IMyWordStatusRepository {
  final IMyWordStatusLocalDataSource _localDataSource;
  final IOutboxWriter _outboxWriter;
  final Uuid _uuid;

  MyWordStatusRepository(
    this._localDataSource,
    this._outboxWriter, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<void>> updateStatus(
    UpdateMyWordStatusRepositoryInputData input,
  ) async {
    try {
      final scope = input.userId ?? guestAccountScope;
      await _localDataSource.runInTransaction(() async {
        final row = await _localDataSource.applyStatusPatch(
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
    return _localDataSource.watchWordStatus(wordId, accountId).map((data) {
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
