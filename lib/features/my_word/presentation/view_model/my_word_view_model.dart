import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/handle_word_registration/handle_word_registration_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/handle_word_registration/i_handle_word_registration_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
//

class MyWordFragmentViewModel extends StateNotifier<MyWordFragmentState> {
  final ILoadMyWordUseCase _loadMyWordInteractor;
  final IRegisterMyWordUseCase _registerMyWordInteractor;
  final IHandleWordRegistrationUseCase _handleWordRegistrationInteractor;

  MyWordFragmentViewModel(
    this._loadMyWordInteractor,
    this._registerMyWordInteractor,
    this._handleWordRegistrationInteractor,
  ) : super(MyWordFragmentState());

  void reset() {
    state = MyWordFragmentState();
  }

  Future<void> loadNext(int size, int currentPage) async {
    log("lodNext");
    //List<int> requiredPages = [_viewModel.currentPage[0], _viewModel.currentPage[1]];

    LoadMyWordInputData input = LoadMyWordInputData(size, currentPage + 1);
    final result = await _loadMyWordInteractor.executeIds(input);
    result.when(
      success: (words) {
        final newData = [...state.myWordIds, ...words];
        state = state.copyWith(myWordIds: newData);
      },
      failure: (error) {
        // エラーハンドリング - ログ出力やユーザーへの通知
        log('Failed to load words: ${error.message}');
      },
    );
  }

  void registerWord(
      {required String headword,
      required String description,
      required void Function() onComplete,
      required void Function() onError,
      required void Function() onInvalid}) async {
    if (headword.isEmpty) {
      onInvalid();
      return;
    }

    final result =
        await _registerMyWordInteractor.execute(RegisterMyWordInputData(
      headword,
      description,
    ));

    result.when(
      success: (_) {
        _handleWordRegistrationInteractor.execute(
            HandleWordRegistrationInputData(true, onComplete, onError));
      },
      failure: (error) {
        log('Failed to register word: ${error.message}');
        _handleWordRegistrationInteractor.execute(
            HandleWordRegistrationInputData(false, onComplete, onError));
      },
    );
  }
}
