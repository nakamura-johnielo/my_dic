
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_status_command_event.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_status_state.dart';

class MyWordStatusCommand extends StateNotifier<MyWordStatusCommandEvent?> {
  MyWordStatusCommand(this._wordId, this.userId, this._updateUsecase)
      : super(null);
  final int _wordId;
  final String? userId;
  final IUpdateMyWordStatusUseCase _updateUsecase;

  void toggleBookmark(bool value) {
    _setBookmark(!value);
  }

  void toggleLearned(bool  value) {
    _setLearned(!value);
  }

  void _setBookmark(bool value ) async {
    
    final res=await _updateUsecase.execute(
      UpdateMyWordStatusInputData(
          _wordId,
          null,
          value?1:0,
          null, // index not needed for stream-based updates
          userId),
    );
    res.when(failure: (error) {
      state = ToggleBookmarkedFailed();
    }, success: (data) {
      state = ToggleBookmarkedSucceeded();
    });

  }

  void _setLearned(bool value ) async {
    final res=await _updateUsecase.execute(
      
      UpdateMyWordStatusInputData(
          _wordId,
          value?1:0,
          null,
          null, // index not needed for stream-based updates
          userId),
    );

    res.when(failure: (error) {
      state = ToggleLearnedFailed();
    }, success: (data) {
      state = ToggleLearnedSucceeded();
    });
  }
}
