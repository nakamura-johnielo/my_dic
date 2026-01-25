import 'package:my_dic/features/my_word/presentation/ui_model/my_word_status_state.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_command.dart';

class MyWordStatusViewModel {
  final MyWordStatusState state;
  final MyWordStatusCommand _command;

  MyWordStatusViewModel(this.state, this._command);

  bool get isLearned => state.isLearned;
  bool get isBookmarked => state.isBookmarked;

  void toggleLearned() => _command.toggleLearned(state.isLearned);
  void toggleBookmark() => _command.toggleBookmark(state.isBookmarked);
}
