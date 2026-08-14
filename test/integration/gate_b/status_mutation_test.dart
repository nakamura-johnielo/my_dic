import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/word_status/internal/presentation/provider/word_status_providers.dart';
import 'package:my_dic/features/word_status/port/composition_contract.dart';
import 'package:my_dic/features/word_status/port/presentation_dependencies.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

void main() {
  test('old session completion is fenced while relogin gets a new command lane',
      () async {
    final commands = _DeferredCommands();
    final ports = _ports(commands);
    final container = ProviderContainer(overrides: [
      wordStatusPortsDependencyProvider.overrideWithValue(ports),
    ]);
    addTearDown(container.dispose);
    const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 3);
    const oldScope = SessionScopeKey(accountScope: 'same-account', epoch: 1);
    const newScope = SessionScopeKey(accountScope: 'same-account', epoch: 2);
    const oldKey = WordStatusEntryKey(scope: oldScope, word: word);
    const newKey = WordStatusEntryKey(scope: newScope, word: word);
    final old = container.read(wordStatusCommandProvider(oldKey).notifier);
    final oldRequest = old.toggleBookmark(false);
    container.invalidate(wordStatusCommandProvider(oldKey));
    commands.completeNext();
    await oldRequest;
    final fresh = container.read(wordStatusCommandProvider(newKey).notifier);
    await fresh.toggleLearned(false);
    expect(commands.scopes, [
      WordStatusScope.account('same-account'),
      WordStatusScope.account('same-account'),
    ]);
    expect(container.read(wordStatusCommandProvider(newKey)).pendingEffect,
        isNotNull);
  });
}

WordStatusPorts _ports(_DeferredCommands commands) => WordStatusPorts(
      reader: _Reader(),
      watcher: _Reader(),
      batchReader: _Reader(),
      commands: commands,
      guestMigration: _GuestMigration(),
    );

final class _Reader
    implements
        WordStatusReaderPort,
        WordStatusWatchPort,
        WordStatusBatchReaderPort {
  @override
  Future<Result<WordStatus>> read(ReadWordStatusQuery query) async =>
      Result.success(WordStatus.initial(query.word));

  @override
  Stream<Result<WordStatus>> watch(ReadWordStatusQuery query) =>
      Stream.value(Result.success(WordStatus.initial(query.word)));

  @override
  Future<Result<WordStatusBatch>> readBatch(
          ReadWordStatusBatchQuery query) async =>
      Result.success(WordStatusBatch(query.words.map(WordStatus.initial)));
}

final class _DeferredCommands implements WordStatusCommandPort {
  final scopes = <WordStatusScope>[];
  final _pending = <Completer<Result<void>>>[];

  @override
  Future<Result<void>> update(UpdateWordStatusCommand command) {
    scopes.add(command.scope);
    final next = Completer<Result<void>>();
    _pending.add(next);
    if (scopes.length > 1) completeNext();
    return next.future;
  }

  void completeNext() => _pending.removeAt(0).complete(const Result.success(null));
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
