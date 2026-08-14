import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_state.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view_model/word_detail_view_model.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

final class _WordDetailViewModelKey {
  const _WordDetailViewModelKey({required this.reader, required this.loadKey});

  final WordDetailQueryPort reader;
  final WordDetailLoadKey loadKey;

  @override
  bool operator ==(Object other) =>
      other is _WordDetailViewModelKey &&
      identical(other.reader, reader) &&
      other.loadKey == loadKey;

  @override
  int get hashCode => Object.hash(identityHashCode(reader), loadKey);
}

final _wordDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<WordDetailViewModel, WordDetailState, _WordDetailViewModelKey>(
        (ref, key) {
  final viewModel = WordDetailViewModel(
    key.reader,
  );
  unawaited(viewModel.initialize(key.loadKey));
  return viewModel;
});

AutoDisposeStateNotifierProvider<WordDetailViewModel, WordDetailState>
    wordDetailViewModelProviderFor({
  required WordDetailQueryPort reader,
  required WordDetailLoadKey loadKey,
}) =>
        _wordDetailViewModelProvider(
          _WordDetailViewModelKey(reader: reader, loadKey: loadKey),
        );
