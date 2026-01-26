import 'package:my_dic/features/esp_jpn_word_status/components/status_button/status_buttons_command.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_state.dart';

/// ViewModel for EspJpnWordStatus feature
/// Provides unified interface for UI state and commands
class EspJpnWordStatusViewModel {
  final WordStatusState state;
  final EspJpnWordStatusCommand _command;

  EspJpnWordStatusViewModel(this.state, this._command);

  bool get isLearned => state.isLearned;
  bool get isBookmarked => state.isBookmarked;
  bool get hasNote => state.hasNote;

  Future<void> toggleLearned() => _command.toggleLearned(state.isLearned);
  Future<void> toggleBookmark() => _command.toggleBookmark(state.isBookmarked);
  Future<void> toggleHasNote() => _command.toggleHasNote(state.hasNote);
}
