import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart';
import 'package:my_dic/features/jpn_esp_word_status/di/di.dart';
import 'package:my_dic/features/my_word/di/view_model_di.dart' as my_word_di;
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_view_model.dart';
import 'package:my_dic/features/word_status/domain/dictionary_direction.dart';
import 'package:my_dic/features/word_status/presentation/status_button.dart';

typedef DictionaryStatusTarget = ({
  DictionaryDirection direction,
  int wordId,
});

final wordStatusViewModelProvider =
    Provider.autoDispose.family<WordStatusViewModel, DictionaryStatusTarget>(
  (ref, target) => switch (target.direction) {
    DictionaryDirection.espJpn =>
      ref.watch(espJpnWordStatusViewModelProvider(target.wordId)),
    DictionaryDirection.jpnEsp =>
      ref.watch(jpnEspWordStatusViewModelProvider(target.wordId)),
  },
);

final myWordStatusViewModelProvider =
    Provider.autoDispose.family<WordStatusViewModel, String>((ref, wordId) {
  return _MyWordStatusViewModel(
    ref.watch(my_word_di.myWordStatusViewModelProvider(wordId)),
  );
});

class _MyWordStatusViewModel implements WordStatusViewModel {
  const _MyWordStatusViewModel(this._delegate);

  final MyWordStatusViewModel _delegate;

  @override
  bool get hasNote => false;

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
