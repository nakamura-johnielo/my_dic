import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/common/enums/feature_tag.dart';
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

class NewMyWordViewModel extends StateNotifier<MyWordState> {
  final ILoadMyWordUseCase _loadMyWordInteractor;
  final IUpdateMyWordStatusUseCase _updateMyWordStatusInteractor;
  final IRegisterMyWordUseCase _registerMyWordInteractor;
  final IHandleWordRegistrationUseCase _handleWordRegistrationInteractor;
  final IUpdateMyWordUseCase _updateMyWordInteractor;
  final IDeleteMyWordUseCase _deleteMyWordInteractor;

  NewMyWordViewModel(
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
    final res = await _loadMyWordInteractor.execute(input);
    final newData=[...state.myWords, ...res];
    state = state.copyWith(myWords: newData);
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

    bool isSuccess = await _registerMyWordInteractor
        .execute(RegisterMyWordInputData(headword, description));

    _handleWordRegistrationInteractor.execute(
        HandleWordRegistrationInputData(isSuccess, onComplete, onError));
  }

  void deleteWord({
    required int wordId,
    required int index,
    required void Function() onComplete,
  }) async {
    DeleteMyWordInputData input = DeleteMyWordInputData(wordId, index);
    bool res = await _deleteMyWordInteractor.execute(input);
    if (res) {
      onComplete();
    }
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

    bool res = await _updateMyWordInteractor.execute(input);
   
    if (res) {
      onComplete();
    }
    /* HandleWordUpdateInputData inputHandle = HandleWordUpdateInputData();
    _handleWordUpdateInteractor.execute(inputHandle); */
  }
}
