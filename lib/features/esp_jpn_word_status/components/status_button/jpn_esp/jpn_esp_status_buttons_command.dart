import 'dart:async';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_command_event.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/i_update_jpn_esp_status_use_case.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_input_data.dart';

class JpnEspWordStatusCommand extends StateNotifier<WordStatusCommandEvent?> {
  JpnEspWordStatusCommand(this._wordId, this._updateInteractor) : super(null);

  final int _wordId;
  final IUpdateJpnEspStatusUseCase _updateInteractor;

  Future<void> toggleBookmark(bool currentValue) async {
    AppLogger.print("toggle jpn_esp bookmark");
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
      UpdateJpnEspStatusInputData(
        wordId: _wordId,
        isBookmarked: FieldUpdate.set(value),
      ),
    );
    AppLogger.print("Complete toggle jpn_esp bookmark");
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
      UpdateJpnEspStatusInputData(
        wordId: _wordId,
        isLearned: FieldUpdate.set(value),
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
      UpdateJpnEspStatusInputData(
        wordId: _wordId,
        hasNote: FieldUpdate.set(value),
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
