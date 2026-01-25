import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/handle_word_registration/handle_word_registration_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/handle_word_registration/i_handle_word_registration_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_input_data.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';

class MyWordViewModel extends StateNotifier<MyWordStateNew> {
  final ILoadMyWordUseCase _loadMyWordInteractor;
  final IRegisterMyWordUseCase _registerMyWordInteractor;
  final IHandleWordRegistrationUseCase _handleWordRegistrationInteractor;
  final IUpdateMyWordUseCase _updateMyWordInteractor;
  final IDeleteMyWordUseCase _deleteMyWordInteractor;

  MyWordViewModel(
      this._loadMyWordInteractor,
      this._registerMyWordInteractor,
      this._handleWordRegistrationInteractor,
      this._updateMyWordInteractor,
      this._deleteMyWordInteractor)
      : super(MyWordStateNew());

  void reset() {
    state = MyWordStateNew();
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
      required void Function() onInvalid, String? userId}) async {
    if (headword.isEmpty) {
      onInvalid();
      return;
    }

    final result = await _registerMyWordInteractor
        .execute(RegisterMyWordInputData(headword, description,userId));

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
    String? userId
  }) async {
    DeleteMyWordInputData input = DeleteMyWordInputData(wordId, index,userId);
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
    String? userId
  }) async {
    UpdateMyWordInputData input =
        UpdateMyWordInputData(myWordId, headword, description, index, userId);

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

  Stream<MyWord> streamMyWordById(int id) {
    return _loadMyWordInteractor.streamMyWordById(id);
  }
  
  // Future<MyWord?> getMyWordById(int id) async {
  //   final result = await _loadMyWordInteractor.getMyWordById(id);
  //   return result.when(
  //     success: (myWord) => myWord,
  //     failure: (error) {
  //       log('Failed to get MyWord by id $id: ${error.message}');
  //       return null;
  //     },
  //   );
  // }
}
