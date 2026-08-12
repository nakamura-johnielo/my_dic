import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/adapter/my_word_application_adapter.dart';
import 'package:my_dic/features/my_word/internal/application/model/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/internal/application/query/i_my_word_item_query_repository.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/delete_my_word/delete_my_word_interactor.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/load_my_word_interactor.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/register_my_word/register_my_word_interactor.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/update/update_my_word/update_my_word_interactor.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart'
    as domain;
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart'
    as domain;
import 'package:my_dic/features/my_word/port/command.dart';
import 'package:my_dic/features/my_word/port/query.dart';

import '../../../../helpers/fake_my_word_repository.dart';

void main() {
  group('MyWordApplicationAdapter', () {
    test('register preserves legacy validation and does not write', () async {
      final repository = FakeMyWordRepository.success();
      final adapter = _adapter(repository: repository);

      final result = await adapter.register(const RegisterMyWordCommand(
        headword: '   ',
        description: 'description',
        accountScope: 'account-a',
      ));

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ValidationError>());
      expect(
        (result.errorOrNull as ValidationError).fieldErrors!['headword'],
        isNotEmpty,
      );
    });

    test('loadIds preserves page validation from the compatibility use case',
        () async {
      final adapter = _adapter(repository: FakeMyWordRepository.success());

      final result = await adapter.loadIds(const LoadMyWordsQuery(
        size: 0,
        page: 0,
        accountScope: 'account-a',
      ));

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ValidationError>());
    });

    test('delete returns the legacy not-found failure unchanged', () async {
      final adapter = _adapter(
        repository: FakeMyWordRepository(
          deleteResult: Result.failure(
            NotFoundError(message: 'My word was not found.'),
          ),
        ),
      );

      final result = await adapter.delete(const DeleteMyWordCommand(
        myWordId: 'missing',
        accountScope: 'account-a',
      ));

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<NotFoundError>());
      expect(result.errorOrNull?.message, 'My word was not found.');
    });

    test('watchItem maps snapshots to public models and preserves absence',
        () async {
      final adapter = _adapter(
        repository: FakeMyWordRepository.success(),
        query: _ItemQueryRepository(Stream.fromIterable([
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

      final items = await adapter
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

MyWordApplicationAdapter _adapter({
  required FakeMyWordRepository repository,
  IMyWordItemQueryRepository? query,
}) =>
    MyWordApplicationAdapter(
      registerUseCase: RegisterMyWordInteractor(repository),
      updateUseCase: UpdateMyWordInteractor(repository),
      deleteUseCase: DeleteMyWordInteractor(repository),
      updateStatusUseCase: _StatusUseCase(),
      loadUseCase: LoadMyWordInteractor(repository),
      itemQueryRepository: query ?? _ItemQueryRepository(const Stream.empty()),
    );

final class _StatusUseCase implements IUpdateMyWordStatusUseCase {
  @override
  Future<Result<void>> execute(UpdateMyWordStatusInputData input) async =>
      const Result.success(null);
}

final class _ItemQueryRepository implements IMyWordItemQueryRepository {
  const _ItemQueryRepository(this.stream);

  final Stream<MyWordItemProjection?> stream;

  @override
  Stream<MyWordItemProjection?> watchItem(
    String myWordId, {
    required String accountId,
  }) =>
      stream;
}
