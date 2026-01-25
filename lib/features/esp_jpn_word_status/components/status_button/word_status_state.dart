import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';

class WordStatusState {
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  WordStatusState({
     this.isLearned =false,
     this.isBookmarked =false,
     this.hasNote =false,
  });

  WordStatusState copyWith({
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
  }) {
    return WordStatusState(
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
    );
  }

  factory WordStatusState.fromAsync(AsyncValue<WordStatus> asyncValue) {
    return asyncValue.when(
      data: (status) => WordStatusState(
        isLearned: status.isLearned,
        isBookmarked: status.isBookmarked,
        hasNote: status.hasNote,
      ),
      loading: () => WordStatusState(),
      error: (_, __) => WordStatusState(),
    );

  }
}
