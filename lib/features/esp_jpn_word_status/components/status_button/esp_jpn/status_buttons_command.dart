import 'dart:async';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_command_event.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_input_data.dart';

class EspJpnWordStatusCommand extends StateNotifier<WordStatusCommandEvent?> {
  EspJpnWordStatusCommand(this._wordId, this._updateInteractor) : super(null);

  final int _wordId;
  final IUpdateStatusUseCase _updateInteractor;

  Future<void> toggleBookmark(bool currentValue) async {
    AppLogger.print("toggle bookmark");
    await _setBookmark(!currentValue);
  }

  Future<void> toggleLearned(bool currentValue) async {
    await _setLearned(!currentValue);
  }

  Future<void> toggleHasNote(bool currentValue) async {
    await _setHasNote(!currentValue);
  }

  Future<void> _setBookmark(bool value) async {
    final res = await _updateInteractor.execute(
      UpdateStatusInputData(wordId: _wordId, isBookmarked: value),
    );
    AppLogger.print("Complete toggle bookmark");
    if (!mounted) return;
    AppLogger.print("mounted");

    res.when(failure: (error) {
      state = ToggleBookmarkedFailed();
    }, success: (data) {
      state = ToggleBookmarkedSucceeded();
    });
  }

  Future<void> _setLearned(bool value) async {
    final res = await _updateInteractor.execute(
      UpdateStatusInputData(
        wordId: _wordId,
        isLearned: value,
      ),
    );

    if (!mounted) return;
    res.when(failure: (error) {
      state = ToggleLearnedFailed();
    }, success: (data) {
      state = ToggleLearnedSucceeded();
    });
  }

  Future<void> _setHasNote(bool value) async {
    final res = await _updateInteractor.execute(
      UpdateStatusInputData(
        wordId: _wordId,
        hasNote: value,
      ),
    );
    if (!mounted) return;
    res.when(failure: (error) {
      state = ToggleNoteFailed();
    }, success: (data) {
      state = ToggleNoteSucceeded();
    });
  }
}
