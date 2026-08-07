import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
//

class MyWordFragmentViewModel extends StateNotifier<MyWordFragmentState> {
  final ILoadMyWordUseCase _loadMyWordInteractor;
  final IRegisterMyWordUseCase _registerMyWordInteractor;

  MyWordFragmentViewModel(
    this._loadMyWordInteractor,
    this._registerMyWordInteractor,
  ) : super(MyWordFragmentState());

  void reset() {
    state = MyWordFragmentState();
  }

  Future<void> loadNext(int size, int currentPage) async {
    AppLogger.print("lodNext");
    LoadMyWordInputData input = LoadMyWordInputData(size, currentPage + 1);
    final result = await _loadMyWordInteractor.executeIds(input);
    result.when(
      success: (words) {
        final newData = [...state.myWordIds, ...words];
        state = state.copyWith(myWordIds: newData);
      },
      failure: (error) {
        // エラーハンドリング - ログ出力やユーザーへの通知
        AppLogger.print('Failed to load words: ${error.message}');
      },
    );
  }

  Future<Result<String>> registerWord({
    required String headword,
    required String description,
    void Function()? onComplete,
    void Function()? onError,
    void Function()? onInvalid,
  }) async {
    final result = await _registerMyWordInteractor.execute(
      RegisterMyWordInputData(headword, description),
    );
    result.when(
      success: (_) => onComplete?.call(),
      failure: (error) {
        AppLogger.print('Failed to register word: ${error.message}');
        onError?.call();
        onInvalid?.call();
      },
    );
    return result;
  }
}
