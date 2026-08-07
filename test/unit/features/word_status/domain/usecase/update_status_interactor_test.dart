import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_interactor.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_input_data.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_interactor.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_repository_input_data.dart';

import '../../../../../helpers/fake_current_session.dart';

class _MockEspJpnRepository extends Mock implements IWordStatusRepository {}

class _MockJpnEspRepository extends Mock
    implements IJpnEspWordStatusRepository {}

void main() {
  const accountId = 'account-a';
  final currentSession = FakeCurrentSession(accountIdOrNull: accountId);
  final noSession = FakeCurrentSession();

  setUpAll(() {
    registerFallbackValue(const UpdateStatusRepositoryInputData(
      wordId: 0,
      isLearned: FieldUpdate.unchanged(),
      isBookmarked: FieldUpdate.unchanged(),
      hasNote: FieldUpdate.unchanged(),
    ));
    registerFallbackValue(const UpdateJpnEspStatusRepositoryInputData(
      wordId: 0,
      isLearned: FieldUpdate.unchanged(),
      isBookmarked: FieldUpdate.unchanged(),
      hasNote: FieldUpdate.unchanged(),
    ));
    registerFallbackValue(WordStatus(wordId: 0));
    registerFallbackValue(JpnEspWordStatus(wordId: 0));
  });

  test('Esp-Jpn local DatabaseError is propagated and remote is skipped',
      () async {
    final repository = _MockEspJpnRepository();
    final error = DatabaseError(message: 'local update failed');
    when(() => repository.updateLocalWordStatus(any(), any(),
            accountId: any(named: 'accountId')))
        .thenAnswer((_) async => Result.failure(error));
    final interactor = UpdateStatusInteractor(repository, noSession);

    final result = await interactor.execute(const UpdateStatusInputData(
      wordId: 1,
      isBookmarked: FieldUpdate.set(false),
    ));

    expect(result.errorOrNull, same(error));
  });

  test('Jpn-Esp local DatabaseError is propagated and remote is skipped',
      () async {
    final repository = _MockJpnEspRepository();
    final error = DatabaseError(message: 'local update failed');
    when(() => repository.updateLocalWordStatus(any(), any(),
            accountId: any(named: 'accountId')))
        .thenAnswer((_) async => Result.failure(error));
    final interactor = UpdateJpnEspStatusInteractor(repository, noSession);

    final result = await interactor.execute(const UpdateJpnEspStatusInputData(
      wordId: 1,
      hasNote: FieldUpdate.set(false),
    ));

    expect(result.errorOrNull, same(error));
  });

  test('Esp-Jpn signed-in update no longer pushes to legacy remote directly',
      () async {
    final repository = _MockEspJpnRepository();
    final updated = WordStatus(
      wordId: 1,
      isLearned: true,
      isBookmarked: false,
      hasNote: true,
      editAt: DateTime.utc(2026, 8, 5),
    );
    when(() => repository.updateLocalWordStatus(any(), any(),
            accountId: any(named: 'accountId')))
        .thenAnswer((_) async => Result.success(updated));
    final interactor = UpdateStatusInteractor(repository, currentSession);

    final result = await interactor.execute(const UpdateStatusInputData(
      wordId: 1,
      isBookmarked: FieldUpdate.set(false),
    ));

    expect(result.isSuccess, isTrue);
    verify(() => repository.updateLocalWordStatus(any(), any(),
        accountId: accountId)).called(1);
  });

  test('Jpn-Esp signed-in update no longer pushes to legacy remote directly',
      () async {
    final repository = _MockJpnEspRepository();
    final updated = JpnEspWordStatus(
      wordId: 1,
      isLearned: true,
      isBookmarked: true,
      hasNote: false,
      editAt: DateTime.utc(2026, 8, 5),
    );
    when(() => repository.updateLocalWordStatus(any(), any(),
            accountId: any(named: 'accountId')))
        .thenAnswer((_) async => Result.success(updated));
    final interactor = UpdateJpnEspStatusInteractor(
      repository,
      currentSession,
    );

    final result = await interactor.execute(const UpdateJpnEspStatusInputData(
      wordId: 1,
      hasNote: FieldUpdate.set(false),
    ));

    expect(result.isSuccess, isTrue);
    verify(() => repository.updateLocalWordStatus(any(), any(),
        accountId: accountId)).called(1);
  });

  test('an unchanged command is a no-op and does not advance persistence',
      () async {
    final repository = _MockEspJpnRepository();
    final interactor = UpdateStatusInteractor(repository, noSession);

    final result = await interactor.execute(
      const UpdateStatusInputData(wordId: 1),
    );

    expect(result.isSuccess, isTrue);
    verifyNever(() => repository.updateLocalWordStatus(any(), any(),
        accountId: any(named: 'accountId')));
  });

  test('an unauthenticated session skips remote updates', () async {
    final repository = _MockEspJpnRepository();
    final updated = WordStatus(wordId: 1, isBookmarked: false);
    when(() => repository.updateLocalWordStatus(any(), any(),
            accountId: any(named: 'accountId')))
        .thenAnswer((_) async => Result.success(updated));
    final interactor = UpdateStatusInteractor(repository, noSession);

    final result = await interactor.execute(const UpdateStatusInputData(
      wordId: 1,
      isBookmarked: FieldUpdate.set(false),
    ));

    expect(result.isSuccess, isTrue);
  });
}
