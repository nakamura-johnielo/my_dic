import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/word_status_composition.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/application/update_word_status.dart';
import 'package:my_dic/features/word_status/application/watch_word_status.dart';
import 'package:my_dic/features/word_status/domain/word_status.dart';
import 'package:my_dic/features/word_status/presentation/dictionary_word_status_view_model.dart';
import 'package:my_dic/features/word_status/presentation/status_button.dart';

/// Resolves a watch use case against the current session scope.
final watchWordStatusUseCaseProvider = Provider<WatchWordStatus>((ref) {
  return WatchWordStatus(
    ref.watch(wordStatusRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

/// Resolves an update use case against the current session scope.
final updateWordStatusUseCaseProvider = Provider<UpdateWordStatus>((ref) {
  return UpdateWordStatus(
    ref.watch(wordStatusRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

/// Streams one catalog word's status. The family key intentionally includes
/// the Catalog identity, so equal numeric IDs in different datasets isolate.
final watchWordStatusProvider =
    StreamProvider.autoDispose.family<WordStatus, CatalogWordRef>((ref, word) {
  return ref.watch(watchWordStatusUseCaseProvider).execute(word);
});

/// Provides the mutation controller for one catalog word.
final wordStatusCommandProvider = StateNotifierProvider.autoDispose
    .family<WordStatusCommand, WordStatusCommandEvent?, CatalogWordRef>(
        (ref, word) {
  return WordStatusCommand(
    word,
    ref.watch(updateWordStatusUseCaseProvider),
  );
});

/// Converts the status stream into stable UI state, retaining prior data on
/// refresh and read failure.
final wordStatusUiStateProvider =
    Provider.autoDispose.family<WordStatusState, CatalogWordRef>((ref, word) {
  return WordStatusState.fromAsync(ref.watch(watchWordStatusProvider(word)));
});

/// The catalog-keyed view model consumed by shared dictionary status UI.
final dictionaryWordStatusViewModelProvider = Provider.autoDispose
    .family<DictionaryWordStatusViewModel, CatalogWordRef>((ref, word) {
  return DictionaryWordStatusViewModel(
    ref.watch(wordStatusUiStateProvider(word)),
    ref.watch(wordStatusCommandProvider(word).notifier),
  );
});

/// Presentation-facing interface for consumers that only need button state.
final dictionaryStatusButtonsViewModelProvider = Provider.autoDispose
    .family<WordStatusViewModel, CatalogWordRef>((ref, word) {
  return ref.watch(dictionaryWordStatusViewModelProvider(word));
});
