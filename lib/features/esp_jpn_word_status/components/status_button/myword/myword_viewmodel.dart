import 'package:my_dic/features/esp_jpn_word_status/components/status_button/i_viewmodel.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_view_model.dart';

/// ViewModel adapter for MyWord feature
/// Wraps existing MyWordStatusViewModel to implement IWordStatusViewModel
class MyWordStatusViewModelAdapter implements IWordStatusViewModel {
  final MyWordStatusViewModel _wrapped;

  MyWordStatusViewModelAdapter(this._wrapped);

  @override
  bool get isLearned => _wrapped.isLearned;
  
  @override
  bool get isBookmarked => _wrapped.isBookmarked;
  
  @override
  bool get hasNote => false; // MyWord doesn't support hasNote

  @override
  Future<void> toggleLearned() async {
    _wrapped.toggleLearned();
  }
  
  @override
  Future<void> toggleBookmark() async {
    _wrapped.toggleBookmark();
  }
  
  @override
  Future<void> toggleHasNote() async {
    // NoOp - MyWord doesn't support hasNote
  }
}
