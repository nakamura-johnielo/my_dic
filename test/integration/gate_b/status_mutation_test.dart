import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/word_status_providers.dart';
import 'package:my_dic/features/word_status/port/repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

void main() {
  test('old session completion is fenced while relogin gets a new command lane',
      () async {
    final repo = _DeferredRepository();
    final container = ProviderContainer(overrides: [
      wordStatusRepositoryDependencyProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
    const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 3);
    const oldScope = SessionScopeKey(accountScope: 'same-account', epoch: 1);
    const newScope = SessionScopeKey(accountScope: 'same-account', epoch: 2);
    final oldKey = WordStatusEntryKey(scope: oldScope, word: word);
    final newKey = WordStatusEntryKey(scope: newScope, word: word);
    final old = container.read(wordStatusCommandProvider(oldKey).notifier);
    final oldRequest = old.toggleBookmark(false);
    container.invalidate(wordStatusCommandProvider(oldKey));
    repo.completeNext();
    await oldRequest;
    final fresh = container.read(wordStatusCommandProvider(newKey).notifier);
    await fresh.toggleLearned(false);
    expect(repo.accounts, ['same-account', 'same-account']);
    expect(container.read(wordStatusCommandProvider(newKey)).pendingEffect,
        isNotNull);
  });
}

class _DeferredRepository implements WordStatusRepository {
  final accounts = <String?>[];
  final _pending = <Completer<Result<WordStatus>>>[];
  @override
  Future<Result<WordStatus?>> get(CatalogWordRef word,
          {required String accountId}) async =>
      const Result.success(null);
  @override
  Stream<WordStatus> watch(CatalogWordRef word, {required String accountId}) =>
      const Stream.empty();
  @override
  Future<Result<WordStatus>> update(CatalogWordRef word,
      {required FieldUpdate<bool> isLearned,
      required FieldUpdate<bool> isBookmarked,
      required FieldUpdate<bool> hasNote,
      required DateTime updatedAt,
      required String? accountId}) {
    accounts.add(accountId);
    final next = Completer<Result<WordStatus>>();
    _pending.add(next);
    if (accounts.length > 1) completeNext();
    return next.future;
  }

  void completeNext() {
    final next = _pending.removeAt(0);
    next.complete(Result.success(WordStatus(
        word: const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 3),
        isLearned: false,
        isBookmarked: false,
        hasNote: false,
        updatedAt: DateTime.utc(2026))));
  }
}
