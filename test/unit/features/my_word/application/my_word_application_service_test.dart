import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/application/model/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/internal/application/my_word_application_service.dart';
import 'package:my_dic/features/my_word/internal/application/query/my_word_item_query.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart'
    as domain;
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart'
    as domain;
import 'package:my_dic/features/my_word/internal/domain/repository/update_my_word_status_record.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_status_repository.dart';
import 'package:my_dic/features/my_word/port/my_word.dart';

import '../../../../helpers/fake_my_word_repository.dart';

void main() {
  group('MyWordApplicationService', () {
    test('register validates before writing', () async {
      final service = _service(wordRepository: FakeMyWordRepository.success());

      final result = await service.register(const RegisterMyWordCommand(
        headword: '   ',
        description: 'description',
        accountScope: 'account-a',
      ));

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ValidationError>());
    });

    test('loadIds validates the page request', () async {
      final service = _service(wordRepository: FakeMyWordRepository.success());

      final result = await service.loadIds(const LoadMyWordsQuery(
        size: 0,
        page: 0,
        accountScope: 'account-a',
      ));

      expect(result.errorOrNull, isA<ValidationError>());
    });

    test('delete preserves repository not-found failure', () async {
      final service = _service(
        wordRepository: FakeMyWordRepository(
          deleteResult: Result.failure(
            NotFoundError(message: 'My word was not found.'),
          ),
        ),
      );

      final result = await service.delete(const DeleteMyWordCommand(
        myWordId: 'missing',
        accountScope: 'account-a',
      ));

      expect(result.errorOrNull, isA<NotFoundError>());
    });

    test('watchItem maps snapshots and preserves absence', () async {
      final service = _service(
        wordRepository: FakeMyWordRepository.success(),
        itemQuery: _ItemQuery(Stream.fromIterable([
          null,
          MyWordItemProjection(
            word: domain.MyWord(
              wordId: 'word-1',
              word: 'hola',
              contents: 'hello',
              editAt: DateTime(2026, 1, 2, 3),
            ),
            status: domain.MyWordStatus(
              wordId: 'word-1',
              isLearned: true,
              hasNote: true,
              editAt: DateTime(2026, 1, 2, 4),
            ),
          ),
        ])),
      );

      final items = await service
          .watchItem(const WatchMyWordItemQuery(
            myWordId: 'word-1',
            accountScope: 'account-a',
          ))
          .toList();

      expect(items.first, isNull);
      expect(items.last!.word.headword, 'hola');
      expect(items.last!.status.isLearned, isTrue);
      expect(items.last!.word.updatedAt.isUtc, isTrue);
      expect(items.last!.status.updatedAt.isUtc, isTrue);
    });
  });
}

MyWordApplicationService _service({
  required FakeMyWordRepository wordRepository,
  MyWordItemQuery? itemQuery,
}) =>
    MyWordApplicationService(
      wordRepository: wordRepository,
      statusRepository: const _StatusRepository(),
      itemQuery: itemQuery ?? const _ItemQuery(Stream.empty()),
    );

final class _StatusRepository implements MyWordStatusRepository {
  const _StatusRepository();

  @override
  Future<Result<void>> updateStatus(
    UpdateMyWordStatusRecord input,
  ) async =>
      const Result.success(null);

  @override
  Stream<domain.MyWordStatus> watchStatus(
    String wordId, {
    required String accountId,
  }) =>
      const Stream.empty();
}

final class _ItemQuery implements MyWordItemQuery {
  const _ItemQuery(this.stream);

  final Stream<MyWordItemProjection?> stream;

  @override
  Stream<MyWordItemProjection?> watchItem(
    String myWordId, {
    required String accountId,
  }) =>
      stream;
}
