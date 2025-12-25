import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/word_status_state.dart';
import 'package:my_dic/core/common/enums/feature_tag.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/usecase/fetch_esp_jpn_status/fetch_esp_jpn_status_usecase.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_input_data.dart';


class EspJpnWordStatusViewModel extends StateNotifier<WordStatusState> {
  EspJpnWordStatusViewModel(
      this._wordId, this._fetchEspJpnStatusUsecase, this._updateInteractor)
      : super(WordStatusState()) {
    _startWatching();
  }

  final int _wordId;
  final FetchEspJpnWordStatusUsecase _fetchEspJpnStatusUsecase;
  final IUpdateStatusUseCase _updateInteractor;

  StreamSubscription<WordStatus>? _statusSubscription;

  // 自動的にStreamを開始
  void _startWatching() {
    _statusSubscription = _fetchEspJpnStatusUsecase.watch(_wordId).listen(
      (status) {
        state = WordStatusState(
          isBookmarked: status.isBookmarked,
          isLearned: status.isLearned,
          hasNote: status.hasNote,
        );
      },
      onError: (error) {
        // エラーハンドリング
        print('Error watching word status $_wordId: $error');
      },
    );
  }

  // Future<void> init(int wordId) async {
  //   await fetchStatus(wordId);
  // }

  // Future<void> fetchStatus(int wordId) async {
  //   final status = await _fetchEspJpnStatusUsecase.execute(wordId);
  //   state = WordStatusState(
  //     isBookmarked: status.isBookmarked,
  //     isLearned: status.isLearned,
  //     hasNote: status.hasNote,
  //   );
  // }

  void toggleBookmark( String userId) {
  final wordId=_wordId;
    _setBookmark(wordId, !state.isBookmarked, userId);
  }

  void toggleLearned( String userId) {
  final wordId=_wordId;
    _setLearned(wordId, !state.isLearned, userId);
  }

  void toggleHasNote( String userId) {
  final wordId=_wordId;
    _setHasNote(wordId, !state.hasNote, userId);
  }

  void _setBookmark(int wordId, bool value, String userId) {
    state = state.copyWith(isBookmarked: value);
    _updateInteractor.execute(
      UpdateStatusInputData(
        userId,
        wordId,
        {
          if (value) FeatureTag.isBookmarked,
          if (state.hasNote) FeatureTag.hasNote,
          if (state.isLearned) FeatureTag.isLearned,
        },
      ),
    );
  }

  void _setLearned(int wordId, bool value, String userId) {
    state = state.copyWith(isLearned: value);
    _updateInteractor.execute(
      UpdateStatusInputData(
        userId,
        wordId,
        {
          if (state.isBookmarked) FeatureTag.isBookmarked,
          if (state.hasNote) FeatureTag.hasNote,
          if (value) FeatureTag.isLearned,
        },
      ),
    );
  }

  void _setHasNote(int wordId, bool value, String userId) {
    state = state.copyWith(hasNote: value);

    _updateInteractor.execute(
      UpdateStatusInputData(
        userId,
        wordId,
        {
          if (state.isBookmarked) FeatureTag.isBookmarked,
          if (value) FeatureTag.hasNote,
          if (state.isLearned) FeatureTag.isLearned,
        },
      ),
    );
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
