import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/status_button.dart'
    as ui;
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/word_status_providers.dart';

/// Final WordStatus presentation entry. The caller supplies its current
/// session identity; all WordStatus reads and commands stay feature-owned.
class DictionaryStatusButtonsEntry extends ConsumerWidget {
  const DictionaryStatusButtonsEntry({super.key, required this.word});
  final CatalogWordRef word;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(sessionScopeKeyProvider);
    if (scope == null)
      return const ui.DictionaryStatusButtons(
          viewModel: _DetachedStatusViewModel());
    final key = WordStatusEntryKey(scope: scope, word: word);
    ref.listen(wordStatusCommandProvider(key), (previous, next) {
      final envelope = next.pendingEffect;
      if (envelope == null || previous?.pendingEffect?.id == envelope.id)
        return;
      ref
          .read(wordStatusCommandProvider(key).notifier)
          .consumeEffect(envelope.id);
      if (envelope.effect case UiNoticeEffect(:final message)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted)
            ScaffoldMessenger.maybeOf(context)
                ?.showSnackBar(SnackBar(content: Text(message)));
        });
      }
    });
    return ui.DictionaryStatusButtons(
      viewModel: ref.watch(dictionaryStatusButtonsViewModelProvider(key)),
    );
  }
}

class _DetachedStatusViewModel implements ui.WordStatusViewModel {
  const _DetachedStatusViewModel();
  @override
  bool get hasNote => false;
  @override
  bool get isBookmarked => false;
  @override
  bool get isLearned => false;
  @override
  bool get isLoading => true;
  @override
  String? get readError => null;
  @override
  Future<void> toggleBookmark() async {}
  @override
  Future<void> toggleHasNote() async {}
  @override
  Future<void> toggleLearned() async {}
}
