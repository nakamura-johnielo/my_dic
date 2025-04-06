import 'dart:developer';

import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/handle_word_registration/handle_word_registration_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/handle_word_registration/i_handle_word_registration_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/handle_word_update/handle_word_update_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/handle_word_update/i_handle_word_update_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/update_my_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';
import 'package:my_dic/_Interface_Adapter/Controller/infinity_scrollable_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/infinity_scrollable_viewmodel.dart';
import 'package:path/path.dart';

class MyWordController extends InfinityScrollableController {
  final ILoadMyWordUseCase _loadMyWordInteractor;
  final IUpdateMyWordStatusUseCase _updateMyWordStatusInteractor;
  final IRegisterMyWordUseCase _registerMyWordInteractor;
  final IHandleWordRegistrationUseCase _handleWordRegistrationInteractor;
  final IUpdateMyWordUseCase _updateMyWordInteractor;
  //final IHandleWordUpdateUseCase _handleWordUpdateInteractor;
  final IDeleteMyWordUseCase _deleteMyWordInteractor;
  //final IHandleWordUpdateUseCase _handleWordDeleteInteractor;

  //final InfinityScrollableViewModel<MyWord> _viewModel;
  //MyWordController(this._loadMyWordInteractor, this._viewModel);
  MyWordController(
    this._loadMyWordInteractor,
    this._updateMyWordStatusInteractor,
    this._registerMyWordInteractor,
    this._handleWordRegistrationInteractor,
    this._updateMyWordInteractor,
    //this._handleWordUpdateInteractor,
    this._deleteMyWordInteractor,
    //this._handleWordDeleteInteractor
  );

  @override
  bool loadNext(int size, List<int> currentPage) {
    log("lodNext");
    //List<int> requiredPages = [_viewModel.currentPage[0], _viewModel.currentPage[1]];

    LoadMyWordInputData input = LoadMyWordInputData(size, currentPage[1] + 1);
    _loadMyWordInteractor.execute(input);
    return true;
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
