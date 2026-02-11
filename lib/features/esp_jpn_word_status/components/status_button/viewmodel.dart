import 'package:my_dic/features/esp_jpn_word_status/components/status_button/i_viewmodel.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/esp_jpn/status_buttons_command.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/esp_jpn/word_status_state.dart';

/// ViewModel for EspJpnWordStatus feature
/// Provides unified interface for UI state and commands
class EspJpnWordStatusViewModel implements IWordStatusViewModel {
  final WordStatusState state;
  final EspJpnWordStatusCommand _command;

  EspJpnWordStatusViewModel(this.state, this._command);

  @override
  bool get isLearned => state.isLearned;
  @override
  bool get isBookmarked => state.isBookmarked;
  @override
  bool get hasNote => state.hasNote;

  @override
  Future<void> toggleLearned() => _command.toggleLearned(state.isLearned);
  @override
  Future<void> toggleBookmark() => _command.toggleBookmark(state.isBookmarked);
  @override
  Future<void> toggleHasNote() => _command.toggleHasNote(state.hasNote);
}
