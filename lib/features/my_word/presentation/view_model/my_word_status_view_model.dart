import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/watch_my_word_status/watch_my_word_status_usecase.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_state.dart';

class MyWordStatusViewModel extends StateNotifier<MyWordStatusState> {
  MyWordStatusViewModel(
      this._wordId, this._watchUsecase, this._updateUsecase)
      : super(MyWordStatusState()) {
    _startWatching();//TODO 修正自動で状態を監視開始
  }

  final int _wordId;
  final WatchMyWordStatusUsecase _watchUsecase;
  final IUpdateMyWordStatusUseCase _updateUsecase;

  StreamSubscription<MyWordStatus>? _statusSubscription;

  // 自動的にStreamを開始
  void _startWatching() {
    _statusSubscription = _watchUsecase.watch(_wordId).listen(
      (status) {
        state = MyWordStatusState(
          isBookmarked: status.isBookmarked,
          isLearned: status.isLearned,
        );
      },
      onError: (error) {
        // エラーハンドリング
        print('Error watching my word status $_wordId: $error');
      },
    );
  }

  void toggleBookmark(String? userId) {
    final wordId = _wordId;
    _setBookmark(wordId, !state.isBookmarked, userId);
  }

  void toggleLearned(String? userId) {
    final wordId = _wordId;
    _setLearned(wordId, !state.isLearned, userId);
  }

  void _setBookmark(int wordId, bool value,String? userId) {
    state = state.copyWith(isBookmarked: value);
    _updateUsecase.execute(
      UpdateMyWordStatusInputData(
        wordId,
        {
          if (value) FeatureTag.isBookmarked,
          if (state.isLearned) FeatureTag.isLearned,
        },
        0, // index not needed for stream-based updates
        userId
      ),
    );
  }

  void _setLearned(int wordId, bool value,String? userId) {
    state = state.copyWith(isLearned: value);
    _updateUsecase.execute(
      UpdateMyWordStatusInputData(
        wordId,
        {
          if (state.isBookmarked) FeatureTag.isBookmarked,
          if (value) FeatureTag.isLearned,
        },
        0, // index not needed for stream-based updates
        userId
      ),
    );
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
