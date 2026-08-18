import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_status_state.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_status_command.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';

class MyWordStatusViewModel {
  final MyWordStatusState state;
  final MyWordStatusCommand _command;

  MyWordStatusViewModel(this.state, this._command);

  bool get isLearned => state.isLearned;
  bool get isBookmarked => state.isBookmarked;
  bool get isLoading => state.status.isInitialLoading;
  String? get readError => switch (state.status) {
        QueryFailure(error: final error) => AppErrorMessage.from(error).text,
        _ => null,
      };

  void toggleLearned() => _command.toggleLearned(state.isLearned);
  void toggleBookmark() => _command.toggleBookmark(state.isBookmarked);
}
