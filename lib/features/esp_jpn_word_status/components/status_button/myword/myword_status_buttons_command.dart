import 'dart:async';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_command_event.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_command.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_status_command_event.dart' as my_word_events;

/// Adapter wrapping MyWordStatusCommand to use shared WordStatusCommandEvent
class MyWordStatusCommandAdapter extends StateNotifier<WordStatusCommandEvent?> {
  MyWordStatusCommandAdapter(this._myWordCommand) : super(null) {
    _listenToMyWordCommand();
  }

  final MyWordStatusCommand _myWordCommand;

  void _listenToMyWordCommand() {
    _myWordCommand.addListener((event) {
      if (event == null) return;
      
      // Map MyWord events to shared WordStatusCommandEvent
      if (event is my_word_events.ToggleBookmarkedSucceeded) {
        state = ToggleBookmarkedSucceeded();
      } else if (event is my_word_events.ToggleBookmarkedFailed) {
        state = ToggleBookmarkedFailed();
      } else if (event is my_word_events.ToggleLearnedSucceeded) {
        state = ToggleLearnedSucceeded();
      } else if (event is my_word_events.ToggleLearnedFailed) {
        state = ToggleLearnedFailed();
      }
    });
  }

  Future<void> toggleBookmark(bool currentValue) async {
    AppLogger.print("toggle myword bookmark");
    _myWordCommand.toggleBookmark(currentValue);
  }

  Future<void> toggleLearned(bool currentValue) async {
    _myWordCommand.toggleLearned(currentValue);
  }

  Future<void> toggleHasNote(bool currentValue) async {
    // MyWord doesn't support hasNote, log warning
    AppLogger.print("MyWord does not support hasNote toggle");
  }
}
