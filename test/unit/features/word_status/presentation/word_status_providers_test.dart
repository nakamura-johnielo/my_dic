import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/word_status/internal/presentation/provider/word_status_providers.dart';
import 'package:my_dic/features/word_status/port/composition_contract.dart';
import 'package:my_dic/features/word_status/port/presentation_dependencies.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

void main() {
  const espWord = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 42,
  );
  const jpnWord = CatalogWordRef(
    catalogId: CatalogId.jpnEspMain,
    wordId: 42,
  );
  const firstScope = SessionScopeKey(accountScope: 'first-account', epoch: 1);
  const secondScope = SessionScopeKey(accountScope: 'second-account', epoch: 2);

  test('watch provider rekeys when the session scope changes', () async {
    final capabilities = _Capabilities();
    final container = _container(capabilities);
    addTearDown(container.dispose);
    final subscription = container.listen(
      watchWordStatusProvider(
        const WordStatusEntryKey(scope: firstScope, word: espWord),
      ),
      (_, __) {},
    );
    addTearDown(subscription.close);

    await container.read(watchWordStatusProvider(
      const WordStatusEntryKey(scope: firstScope, word: espWord),
    ).future);
    expect(capabilities.scopes, [WordStatusScope.account('first-account')]);

    await container.read(watchWordStatusProvider(
      const WordStatusEntryKey(scope: secondScope, word: espWord),
    ).future);
    expect(capabilities.scopes, [
      WordStatusScope.account('first-account'),
      WordStatusScope.account('second-account'),
    ]);
  });

  test('CatalogWordRef provider families isolate equal word IDs by catalog',
      () async {
    final capabilities = _Capabilities();
    final container = _container(capabilities);
    addTearDown(container.dispose);

    final esp = await container.read(watchWordStatusProvider(
      const WordStatusEntryKey(scope: firstScope, word: espWord),
    ).future);
    final jpn = await container.read(watchWordStatusProvider(
      const WordStatusEntryKey(scope: firstScope, word: jpnWord),
    ).future);

    expect(esp.dataOrNull!.word, espWord);
    expect(jpn.dataOrNull!.word, jpnWord);
    expect(capabilities.words, [espWord, jpnWord]);
  });
}

ProviderContainer _container(_Capabilities capabilities) =>
    ProviderContainer(overrides: [
      wordStatusPortsDependencyProvider.overrideWithValue(
        capabilities.ports,
      ),
    ]);

final class _Capabilities
    implements
        WordStatusReaderPort,
        WordStatusWatchPort,
        WordStatusBatchReaderPort,
        WordStatusCommandPort {
  _Capabilities() {
    ports = WordStatusPorts(
      reader: this,
      watcher: this,
      batchReader: this,
      commands: this,
      guestMigration: _GuestMigration(),
    );
  }

  late final WordStatusPorts ports;
  final scopes = <WordStatusScope>[];
  final words = <CatalogWordRef>[];

  @override
  Future<Result<WordStatus>> read(ReadWordStatusQuery query) async =>
      Result.success(_status(query.word));

  @override
  Stream<Result<WordStatus>> watch(ReadWordStatusQuery query) {
    scopes.add(query.scope);
    words.add(query.word);
    return Stream.value(Result.success(_status(query.word)));
  }

  @override
  Future<Result<WordStatusBatch>> readBatch(
          ReadWordStatusBatchQuery query) async =>
      Result.success(WordStatusBatch(query.words.map(_status)));

  @override
  Future<Result<void>> update(UpdateWordStatusCommand command) async =>
      const Result.success(null);

  WordStatus _status(CatalogWordRef word) => WordStatus(
        word: word,
        isLearned: word.catalogId == CatalogId.espJpnMain,
        isBookmarked: false,
        hasNote: false,
        updatedAt: DateTime.utc(2026, 8, 9),
      );
}

final class _GuestMigration implements WordStatusGuestMigrationPort {
  @override
  Future<WordStatusGuestRowCounts> countGuestRows() async =>
      const WordStatusGuestRowCounts(espJpn: 0, jpnEsp: 0);

  @override
  Future<void> migrateGuestRows({
    required String accountId,
    required String migrationId,
    required DateTime Function() clock,
  }) async {}
}
