import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/myword/myword_viewmodel.dart';
import 'package:my_dic/features/my_word/di/view_model_di.dart';

/// DI adapter for MyWord status buttons
/// Wraps existing MyWord providers to work with shared status button interface

final mywordStatusViewModelProvider =
    Provider.autoDispose.family<MyWordStatusViewModelAdapter, String>((ref, wordId) {
  // Get the existing MyWord ViewModel
  final myWordViewModel = ref.watch(myWordStatusViewModelProvider(wordId));

  // Wrap it in the adapter
  return MyWordStatusViewModelAdapter(myWordViewModel);
});
