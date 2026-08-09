import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/di/view_model_di.dart' as my_word_di;
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_view_model.dart';
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
        ref.watch(my_word_di.myWordStatusViewModelProvider(wordId)),
      ),
    );
  }
}

class _MyWordStatusViewModel implements status_ui.WordStatusViewModel {
  const _MyWordStatusViewModel(this._delegate);

  final MyWordStatusViewModel _delegate;

  @override
  bool get hasNote => false;

  @override
  bool get isLoading => _delegate.isLoading;

  @override
  String? get readError => _delegate.readError;

  @override
  bool get isBookmarked => _delegate.isBookmarked;

  @override
  bool get isLearned => _delegate.isLearned;

  @override
  Future<void> toggleBookmark() async => _delegate.toggleBookmark();

  @override
  Future<void> toggleHasNote() async {}

  @override
  Future<void> toggleLearned() async => _delegate.toggleLearned();
}
