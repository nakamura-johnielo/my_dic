import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_command_event.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_state.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/fetch_esp_jpn_status/fetch_esp_jpn_status_usecase.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_input_data.dart';

class EspJpnWordStatusCommand extends StateNotifier<WordStatusCommandEvent?> {
  EspJpnWordStatusCommand(this._wordId, this._updateInteractor) : super(null);

  final int _wordId;
  // final FetchEspJpnWordStatusUsecase _fetchEspJpnStatusUsecase;
  final IUpdateStatusUseCase _updateInteractor;

  Future<void> toggleBookmark( bool currentValue) async {
    print("toggle bookmark");
    await _setBookmark( !currentValue);
  }

  Future<void> toggleLearned( bool currentValue) async {
    await _setLearned(!currentValue);
  }

  Future<void> toggleHasNote( bool currentValue) async {
    await _setHasNote(!currentValue );
  }

  Future<void> _setBookmark( bool value) async {
    //state = state.copyWith(isBookmarked: value);
    final res = await _updateInteractor.execute(
      UpdateStatusInputData(
          wordId: _wordId, isBookmarked: value),
    );
    print("Complete toggle bookmark");
    if (!mounted) return;
    print("mounted");

    res.when(failure: (error) {
      state = ToggleBookmarkedFailed();
    }, success: (data) {
      state = ToggleBookmarkedSucceeded();
    });
  }

  Future<void> _setLearned( bool value) async {
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

  Future<void> _setHasNote( bool value) async {
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
