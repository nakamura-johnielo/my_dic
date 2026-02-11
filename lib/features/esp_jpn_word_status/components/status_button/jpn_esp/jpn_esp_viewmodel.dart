import 'package:my_dic/features/esp_jpn_word_status/components/status_button/i_viewmodel.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/jpn_esp/jpn_esp_status_buttons_command.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/jpn_esp/jpn_esp_word_status_state.dart';

/// ViewModel for JpnEspWordStatus feature
/// Provides unified interface for UI state and commands
class JpnEspWordStatusViewModel implements IWordStatusViewModel {
  final JpnEspWordStatusState state;
  final JpnEspWordStatusCommand _command;

  JpnEspWordStatusViewModel(this.state, this._command);

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
