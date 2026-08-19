import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/internal/presentation/component/status_button.dart'
    as ui;
import 'package:my_dic/features/word_status/internal/presentation/provider/word_status_providers.dart';
import 'package:my_dic/features/word_status/port/composition_contract.dart';

/// 最終的な WordStatus 表示エントリです。呼び出し元が現在のセッション識別子を提供し、
/// すべての WordStatus 読み取りとコマンドは機能側が所有します。
class DictionaryStatusButtonsEntry extends ConsumerWidget {
  const DictionaryStatusButtonsEntry({
    super.key,
    required this.word,
    required this.ports,
    this.scope,
  });
  final CatalogWordRef word;
  final SessionScopeKey? scope;
  final WordStatusPorts ports;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedScope = scope ?? ref.watch(sessionScopeKeyProvider);
    if (resolvedScope == null)
      return const ui.DictionaryStatusButtons(
          viewModel: _DetachedStatusViewModel());
    final key = WordStatusEntryKey(
      scope: resolvedScope,
      word: word,
      ports: ports,
    );
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
