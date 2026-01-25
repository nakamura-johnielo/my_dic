import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';

class MyWordStatusState {
  final bool isLearned;
  final bool isBookmarked;

  MyWordStatusState({
    this.isLearned = false,
    this.isBookmarked = false,
  });

  MyWordStatusState copyWith({
    bool? isLearned,
    bool? isBookmarked,
  }) {
    return MyWordStatusState(
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory MyWordStatusState.fromAsync(AsyncValue<MyWordStatus> async) {
    return async.when(
      data: (status) => MyWordStatusState(
        isLearned: status.isLearned,
        isBookmarked: status.isBookmarked,
      ),
      loading: () => MyWordStatusState(),
      error: (_, __) => MyWordStatusState(),
    );
  }
}
