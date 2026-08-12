import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/internal/application/update_word_status.dart';
import 'package:my_dic/features/word_status/internal/application/watch_word_status.dart';
import 'package:my_dic/features/word_status/internal/presentation/viewmodel/dictionary_word_status_view_model.dart';
import 'package:my_dic/features/word_status/internal/presentation/model/dictionary_word_status_command.dart';
import 'package:my_dic/features/word_status/internal/presentation/component/status_button.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';
import 'package:my_dic/features/word_status/port/repository.dart';

/// App composition supplies the concrete repository at the root ProviderScope.
final wordStatusRepositoryDependencyProvider = Provider<IWordStatusRepository>(
  (_) => throw StateError('WordStatusRepository dependency was not supplied.'),
);

final class WordStatusEntryKey {
  const WordStatusEntryKey({required this.scope, required this.word});
  final SessionScopeKey scope;
  final CatalogWordRef word;
  @override
  bool operator ==(Object other) =>
      other is WordStatusEntryKey && other.scope == scope && other.word == word;
  @override
  int get hashCode => Object.hash(scope, word);
}

final watchWordStatusUseCaseProvider = Provider<WatchWordStatusInteractor>(
    (ref) => WatchWordStatusInteractor(
        ref.watch(wordStatusRepositoryDependencyProvider)));
final updateWordStatusUseCaseProvider = Provider<UpdateWordStatusInteractor>(
    (ref) => UpdateWordStatusInteractor(
        ref.watch(wordStatusRepositoryDependencyProvider)));
final watchWordStatusProvider = StreamProvider.autoDispose
    .family<WordStatus, WordStatusEntryKey>((ref, entry) => ref
        .watch(watchWordStatusUseCaseProvider)
        .execute(entry.word, accountScope: entry.scope.accountScope));
final wordStatusCommandProvider = StateNotifierProvider.autoDispose.family<
        DictionaryWordStatusCommand,
        DictionaryWordStatusCommandState,
        WordStatusEntryKey>(
    (ref, entry) => DictionaryWordStatusCommand(
        entry.word, ref.watch(updateWordStatusUseCaseProvider), entry.scope));
final wordStatusUiStateProvider = Provider.autoDispose
    .family<WordStatusState, WordStatusEntryKey>((ref, entry) =>
        WordStatusState.fromAsync(ref.watch(watchWordStatusProvider(entry))));
final dictionaryWordStatusViewModelProvider = Provider.autoDispose
    .family<DictionaryWordStatusViewModel, WordStatusEntryKey>((ref, entry) =>
        DictionaryWordStatusViewModel(
            ref.watch(wordStatusUiStateProvider(entry)),
            ref.watch(wordStatusCommandProvider(entry).notifier)));
final dictionaryStatusButtonsViewModelProvider = Provider.autoDispose
    .family<WordStatusViewModel, WordStatusEntryKey>((ref, entry) =>
        ref.watch(dictionaryWordStatusViewModelProvider(entry)));
