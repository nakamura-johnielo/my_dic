import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/dictionary_status_buttons_entry.dart';
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/word_status_providers.dart';
import 'package:my_dic/features/word_status/port/repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

void main() {
  const scope = SessionScopeKey(accountScope: 'a', epoch: 1);
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 5);
  testWidgets('failure effect is shown once then consumed by its entry owner',
      (tester) async {
    final container = ProviderContainer(overrides: [
      sessionScopeKeyProvider.overrideWithValue(scope),
      wordStatusRepositoryDependencyProvider.overrideWithValue(_Repository()),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
            home: Scaffold(body: DictionaryStatusButtonsEntry(word: word)))));
    await tester.pump();
    await tester.tap(find.byType(TextButton).first);
    await tester.pump();
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    final key = WordStatusEntryKey(scope: scope, word: word);
    expect(
        container.read(wordStatusCommandProvider(key)).pendingEffect, isNull);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

class _Repository implements WordStatusRepository {
  @override
  Future<Result<WordStatus?>> get(CatalogWordRef word,
          {required String accountId}) async =>
      Result.success(_status(word));
  @override
  Stream<WordStatus> watch(CatalogWordRef word, {required String accountId}) =>
      Stream.value(_status(word));
  @override
  Future<Result<WordStatus>> update(CatalogWordRef word,
          {required FieldUpdate<bool> isLearned,
          required FieldUpdate<bool> isBookmarked,
          required FieldUpdate<bool> hasNote,
          required DateTime updatedAt,
          required String? accountId}) async =>
      Result.failure(DatabaseError(message: 'offline'));
}

WordStatus _status(CatalogWordRef word) => WordStatus(
    word: word,
    isLearned: false,
    isBookmarked: false,
    hasNote: false,
    updatedAt: DateTime.utc(2026));
