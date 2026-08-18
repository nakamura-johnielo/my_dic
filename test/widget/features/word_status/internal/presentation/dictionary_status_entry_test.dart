import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/word_status/internal/presentation/provider/word_status_providers.dart';
import 'package:my_dic/features/word_status/internal/presentation/view/dictionary_status_buttons_entry.dart';
import 'package:my_dic/features/word_status/port/composition_contract.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

void main() {
  const scope = SessionScopeKey(accountScope: 'account-a', epoch: 1);
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 5);

  testWidgets('failure effect is shown once then consumed by its entry owner',
      (tester) async {
    final capabilities = _Capabilities();
    final ports = capabilities.ports;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: DictionaryStatusButtonsEntry(
            word: word,
            scope: scope,
            ports: ports,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.byType(TextButton).first);
    await tester.pump();
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    final key = WordStatusEntryKey(scope: scope, word: word, ports: ports);
    expect(container.read(wordStatusCommandProvider(key)).pendingEffect, isNull);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

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

  @override
  Future<Result<WordStatus>> read(ReadWordStatusQuery query) async =>
      Result.success(_status(query.word));

  @override
  Stream<Result<WordStatus>> watch(ReadWordStatusQuery query) =>
      Stream.value(Result.success(_status(query.word)));

  @override
  Future<Result<WordStatusBatch>> readBatch(
          ReadWordStatusBatchQuery query) async =>
      Result.success(WordStatusBatch(query.words.map(_status)));

  @override
  Future<Result<void>> update(UpdateWordStatusCommand command) async =>
      const Result.failure(WordStatusWriteError.storage());
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

WordStatus _status(CatalogWordRef word) => WordStatus(
      word: word,
      isLearned: false,
      isBookmarked: false,
      hasNote: false,
      updatedAt: DateTime.utc(2026),
    );
