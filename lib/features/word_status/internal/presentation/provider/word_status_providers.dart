import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/word_status/internal/presentation/component/status_button.dart';
import 'package:my_dic/features/word_status/internal/presentation/model/dictionary_word_status_command.dart';
import 'package:my_dic/features/word_status/internal/presentation/viewmodel/dictionary_word_status_view_model.dart';
import 'package:my_dic/features/word_status/port/composition_contract.dart';
import 'package:my_dic/features/word_status/port/presentation_dependencies.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

final class WordStatusEntryKey {
  const WordStatusEntryKey({
    required this.scope,
    required this.word,
    this.ports,
  });

  final SessionScopeKey scope;
  final CatalogWordRef word;
  final WordStatusPorts? ports;

  @override
  bool operator ==(Object other) =>
      other is WordStatusEntryKey &&
      other.scope == scope &&
      other.word == word &&
      identical(other.ports, ports);

  @override
  int get hashCode => Object.hash(scope, word, identityHashCode(ports));
}

WordStatusPorts _ports(Ref ref, WordStatusEntryKey entry) =>
    entry.ports ?? ref.watch(wordStatusPortsDependencyProvider);

WordStatusScope _scope(SessionScopeKey scope) =>
    scope.accountScope == guestAccountScope
        ? const WordStatusScope.guest()
        : WordStatusScope.account(scope.accountScope);

final watchWordStatusProvider = StreamProvider.autoDispose
    .family<Result<WordStatus>, WordStatusEntryKey>(
  (ref, entry) => _ports(ref, entry).watcher.watch(
        ReadWordStatusQuery(scope: _scope(entry.scope), word: entry.word),
      ),
);

final wordStatusCommandProvider = StateNotifierProvider.autoDispose.family<
    DictionaryWordStatusCommand,
    DictionaryWordStatusCommandState,
    WordStatusEntryKey>(
  (ref, entry) => DictionaryWordStatusCommand(
    entry.word,
    _ports(ref, entry).commands,
    entry.scope,
  ),
);

final wordStatusUiStateProvider = Provider.autoDispose
    .family<WordStatusState, WordStatusEntryKey>(
  (ref, entry) =>
      WordStatusState.fromAsync(ref.watch(watchWordStatusProvider(entry))),
);

final dictionaryWordStatusViewModelProvider = Provider.autoDispose
    .family<DictionaryWordStatusViewModel, WordStatusEntryKey>(
  (ref, entry) => DictionaryWordStatusViewModel(
    ref.watch(wordStatusUiStateProvider(entry)),
    ref.watch(wordStatusCommandProvider(entry).notifier),
  ),
);

final dictionaryStatusButtonsViewModelProvider = Provider.autoDispose
    .family<WordStatusViewModel, WordStatusEntryKey>(
  (ref, entry) => ref.watch(dictionaryWordStatusViewModelProvider(entry)),
);
