import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_status_state.dart';

/// Adapter for MyWordStatusState - simply re-exports the existing state
/// with additional hasNote property for compatibility
class MyWordStatusStateAdapter {
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  MyWordStatusStateAdapter({
    this.isLearned = false,
    this.isBookmarked = false,
    this.hasNote = false,
  });

  MyWordStatusStateAdapter copyWith({
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
  }) {
    return MyWordStatusStateAdapter(
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
    );
  }

  factory MyWordStatusStateAdapter.fromMyWordState(MyWordStatusState state) {
    return MyWordStatusStateAdapter(
      isLearned: state.isLearned,
      isBookmarked: state.isBookmarked,
      hasNote: false, // MyWord doesn't support hasNote
    );
  }
}
