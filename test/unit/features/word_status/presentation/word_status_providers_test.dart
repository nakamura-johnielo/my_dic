import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/word_status_composition.dart';
import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/application/port/word_status_repository.dart';
import 'package:my_dic/features/word_status/domain/word_status.dart';
import 'package:my_dic/features/word_status/presentation/word_status_providers.dart';

import '../../../../helpers/fake_current_session.dart';

final _testCurrentSessionProvider = StateProvider<CurrentSession>(
  (ref) => FakeCurrentSession(accountIdOrNull: 'first-account'),
);

void main() {
  const espWord = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 42,
  );
  const jpnWord = CatalogWordRef(
    catalogId: CatalogId.jpnEspMain,
    wordId: 42,
  );

  test('watch provider restarts with the updated account session', () async {
    final repository = _RecordingRepository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final subscription =
        container.listen(watchWordStatusProvider(espWord), (_, __) {});
    addTearDown(subscription.close);

    await container.read(watchWordStatusProvider(espWord).future);
    expect(repository.accountIds, ['first-account']);

    container.read(_testCurrentSessionProvider.notifier).state =
        FakeCurrentSession(accountIdOrNull: 'second-account');
    await container.read(watchWordStatusProvider(espWord).future);

    expect(repository.accountIds, ['first-account', 'second-account']);
  });

  test('CatalogWordRef provider families isolate equal word IDs by catalog',
      () async {
    final repository = _RecordingRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    final esp = await container.read(watchWordStatusProvider(espWord).future);
    final jpn = await container.read(watchWordStatusProvider(jpnWord).future);

    expect(esp.word, espWord);
    expect(jpn.word, jpnWord);
    expect(repository.words, [espWord, jpnWord]);
  });
}

ProviderContainer _container(_RecordingRepository repository) {
  return ProviderContainer(overrides: [
    wordStatusRepositoryProvider.overrideWithValue(repository),
    currentSessionProvider.overrideWith(
      (ref) => ref.watch(_testCurrentSessionProvider),
    ),
  ]);
}

final class _RecordingRepository implements WordStatusRepository {
  final accountIds = <String>[];
  final words = <CatalogWordRef>[];

  @override
  Future<Result<WordStatus?>> get(CatalogWordRef word,
          {required String accountId}) async =>
      Result.success(null);

  @override
  Future<Result<WordStatus>> update(
    CatalogWordRef word, {
    required FieldUpdate<bool> isLearned,
    required FieldUpdate<bool> isBookmarked,
    required FieldUpdate<bool> hasNote,
    required DateTime updatedAt,
    required String? accountId,
  }) async =>
      Result.success(_status(word));

  @override
  Stream<WordStatus> watch(CatalogWordRef word, {required String accountId}) {
    accountIds.add(accountId);
    words.add(word);
    return Stream.value(_status(word));
  }

  WordStatus _status(CatalogWordRef word) => WordStatus(
        word: word,
        isLearned: word.catalogId == CatalogId.espJpnMain,
        isBookmarked: false,
        hasNote: false,
        updatedAt: DateTime.utc(2026, 8, 9),
      );
}
