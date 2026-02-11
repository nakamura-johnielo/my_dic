import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';

class JpnEspWordStatusState {
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  JpnEspWordStatusState({
     this.isLearned = false,
     this.isBookmarked = false,
     this.hasNote = false,
  });

  JpnEspWordStatusState copyWith({
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
  }) {
    return JpnEspWordStatusState(
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
    );
  }

  factory JpnEspWordStatusState.fromAsync(AsyncValue<JpnEspWordStatus> asyncValue) {
    return asyncValue.when(
      data: (status) => JpnEspWordStatusState(
        isLearned: status.isLearned,
        isBookmarked: status.isBookmarked,
        hasNote: status.hasNote,
      ),
      loading: () => JpnEspWordStatusState(),
      error: (_, __) => JpnEspWordStatusState(),
    );
  }
}
