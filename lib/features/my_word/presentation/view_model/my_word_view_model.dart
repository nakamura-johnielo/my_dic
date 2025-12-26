import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/handle_word_registration/handle_word_registration_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/handle_word_registration/i_handle_word_registration_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';

class MyWordViewModel extends StateNotifier<MyWordState> {
  final ILoadMyWordUseCase _loadMyWordInteractor;
  final IUpdateMyWordStatusUseCase _updateMyWordStatusInteractor;
  final IRegisterMyWordUseCase _registerMyWordInteractor;
  final IHandleWordRegistrationUseCase _handleWordRegistrationInteractor;
  final IUpdateMyWordUseCase _updateMyWordInteractor;
  final IDeleteMyWordUseCase _deleteMyWordInteractor;

  MyWordViewModel(
      this._loadMyWordInteractor,
      this._updateMyWordStatusInteractor,
      this._registerMyWordInteractor,
      this._handleWordRegistrationInteractor,
      this._updateMyWordInteractor,
      this._deleteMyWordInteractor)
      : super(MyWordState());

  Future<void> loadNext(int size, int currentPage) async {
    log("lodNext");
    //List<int> requiredPages = [_viewModel.currentPage[0], _viewModel.currentPage[1]];

    LoadMyWordInputData input = LoadMyWordInputData(size, currentPage + 1);
    final result = await _loadMyWordInteractor.execute(input);
    result.when(
      success: (words) {
        final newData = [...state.myWords, ...words];
        state = state.copyWith(myWords: newData);
      },
      failure: (error) {
        // エラーハンドリング - ログ出力やユーザーへの通知
        log('Failed to load words: ${error.message}');
      },
    );
  }

  void updateWordStatus(
    int index,
    int wordId,
    bool isBookmarked,
    bool isLearned,
    //bool hasNote,
  ) {
    log("updatecontroller");

    Set<FeatureTag> status = {
      if (isBookmarked) FeatureTag.isBookmarked,
      if (isLearned) FeatureTag.isLearned,
    };
    UpdateMyWordStatusInputData input =
        UpdateMyWordStatusInputData(wordId, status, index);
    _updateMyWordStatusInteractor.execute(input);
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

    final result = await _registerMyWordInteractor
        .execute(RegisterMyWordInputData(headword, description));

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

  void deleteWord({
    required int wordId,
    required int index,
    required void Function() onComplete,
  }) async {
    DeleteMyWordInputData input = DeleteMyWordInputData(wordId, index);
    final result = await _deleteMyWordInteractor.execute(input);
    result.when(
      success: (_) {
        onComplete();
      },
      failure: (error) {
        log('Failed to delete word: ${error.message}');
        // エラーをUIに通知する必要がある場合はここで処理
      },
    );
    /* HandleWordUpdateInputData inputHandle = HandleWordUpdateInputData();
    _handleWordDeleteInteractor.execute(inputHandle); */
  }

  void updateWord({
    required int myWordId,
    required String headword,
    required String description,
    required int index,
    required void Function() onComplete,
  }) async {
    UpdateMyWordInputData input =
        UpdateMyWordInputData(myWordId, headword, description, index);

    final result = await _updateMyWordInteractor.execute(input);

    result.when(
      success: (_) {
        onComplete();
      },
      failure: (error) {
        log('Failed to update word: ${error.message}');
        // エラーをUIに通知する必要がある場合はここで処理
      },
    );
    /* HandleWordUpdateInputData inputHandle = HandleWordUpdateInputData();
    _handleWordUpdateInteractor.execute(inputHandle); */
  }
}
