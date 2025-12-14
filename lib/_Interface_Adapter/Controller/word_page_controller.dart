import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_input_data.dart';

class WordPageController {
  final IFetchDictionaryUseCase _fetchDictionaryUseCase;
  final IFetchConjugationUseCase _fetchConjugationUseCase;
  final IUpdateStatusUseCase _updateStatusInteractor;

  WordPageController(this._fetchDictionaryUseCase,
      this._fetchConjugationUseCase, this._updateStatusInteractor);

  void fetchDictionaryById(int wordId) async {
    FetchDictionaryInputData input = FetchDictionaryInputData(wordId);
    await _fetchDictionaryUseCase.execute(input);
  }

  void fetchConjugacionById(int wordId) async {
    FetchConjugationInputData input = FetchConjugationInputData(wordId);
    await _fetchConjugationUseCase.execute(input);
  }

  void updateWordStatus(
    int index,
    int wordId,
    bool isBookmarked,
    bool isLearned,
    bool hasNote,
  ) {
    //log("updatecontroller");

    Set<FeatureTag> status = {
      if (isBookmarked) FeatureTag.isBookmarked,
      if (isLearned) FeatureTag.isLearned,
      if (hasNote) FeatureTag.hasNote,
    };
    UpdateStatusInputData input = UpdateStatusInputData(wordId, status, index);
    _updateStatusInteractor.execute(input);
  }
}
