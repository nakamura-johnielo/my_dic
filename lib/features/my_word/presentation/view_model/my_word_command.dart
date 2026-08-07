import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/update/update_my_word/update_my_word_input_data.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_event.dart';

class MyWordCommand extends StateNotifier<MyWordCommandEvent?> {
  final String _wordId;
  final IUpdateMyWordUseCase _updateMyWordInteractor;
  final IDeleteMyWordUseCase _deleteMyWordInteractor;

  MyWordCommand(
    this._wordId,
    this._updateMyWordInteractor,
    this._deleteMyWordInteractor,
  ) : super(null);

  void deleteWord({required void Function() onComplete}) async {
    DeleteMyWordInputData input = DeleteMyWordInputData(_wordId);
    final result = await _deleteMyWordInteractor.execute(input);
    result.when(
      success: (_) {
        onComplete();
        state = DeleteSucceeded();
      },
      failure: (error) {
        AppLogger.print('Failed to delete word: ${error.message}');
        state = DeleteFailed();
        // エラーをUIに通知する必要がある場合はここで処理
      },
    );
  }

  void updateWord(
      {required String headword,
      required String description,
      required void Function() onComplete}) async {
    UpdateMyWordInputData input =
        UpdateMyWordInputData(_wordId, headword, description);

    final result = await _updateMyWordInteractor.execute(input);

    result.when(
      success: (_) {
        onComplete();
        state = UpdateSucceeded();
      },
      failure: (error) {
        AppLogger.print('Failed to update word: ${error.message}');
        state = UpdateFailed();
        // エラーをUIに通知する必要がある場合はここで処理
      },
    );
  }
}
