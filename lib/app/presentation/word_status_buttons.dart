import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/di/view_model_di.dart' as my_word_di;
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_command.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/presentation/word_status_providers.dart';
import 'package:my_dic/features/word_status/presentation/status_button.dart'
    as status_ui;

/// App-level composition for status controls used across presentation features.
///
/// This is deliberately outside individual features: it composes the
/// catalog-aware view model while the shared UI remains feature-owned.
class DictionaryStatusButtons extends ConsumerWidget {
  const DictionaryStatusButtons({
    super.key,
    required this.word,
  });

  final CatalogWordRef word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(dictionaryStatusButtonsViewModelProvider(word));
    return status_ui.DictionaryStatusButtons(viewModel: viewModel);
  }
}

class MyWordStatusButtons extends ConsumerWidget {
  const MyWordStatusButtons({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return status_ui.MyWordStatusButtons(
      viewModel: _MyWordStatusViewModel(
        item: ref.watch(my_word_di.myWordItemUiModelProvider(wordId)),
        command:
            ref.read(my_word_di.myWordStatusCommandProvider(wordId).notifier),
      ),
    );
  }
}

class _MyWordStatusViewModel implements status_ui.WordStatusViewModel {
  const _MyWordStatusViewModel({required this.item, required this.command});

  final AsyncValue<MyWordItemUiModel?> item;
  final MyWordStatusCommand command;

  @override
  bool get hasNote => false;

  @override
  bool get isLoading => item.isLoading;

  @override
  String? get readError => item.whenOrNull(error: (error, _) => '$error');

  @override
  bool get isBookmarked => item.valueOrNull?.isBookmarked ?? false;

  @override
  bool get isLearned => item.valueOrNull?.isLearned ?? false;

  @override
  Future<void> toggleBookmark() => command.toggleBookmark(isBookmarked);

  @override
  Future<void> toggleHasNote() async {}

  @override
  Future<void> toggleLearned() => command.toggleLearned(isLearned);
}
