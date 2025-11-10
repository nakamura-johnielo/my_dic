import 'package:flutter_riverpod/flutter_riverpod.dart';
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/button/my_icon_button.dart';
//import 'package:my_dic/_Interface_Adapter/Controller/word_status_controller.dart';

@immutable
class WordStatus {
  final bool isBookmarked;
  final bool isLearned;
  final bool hasNote;

  const WordStatus({
    this.isBookmarked = false,
    this.isLearned = false,
    this.hasNote = false,
  });

  WordStatus copyWith({
    bool? isBookmarked,
    bool? isLearned,
    bool? hasNote,
  }) {
    return WordStatus(
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLearned: isLearned ?? this.isLearned,
      hasNote: hasNote ?? this.hasNote,
    );
  }
}

//!TODO DB操作add
class WordStatusViewModel extends StateNotifier<Map<int, WordStatus>> {
  WordStatusViewModel() : super(const {});

  WordStatus getStatus(int wordId) => state[wordId] ?? const WordStatus();

  void setBookmark(int wordId, bool value) {
    final current = getStatus(wordId);
    state = {
      ...state,
      wordId: current.copyWith(isBookmarked: value),
    };
  }

  void toggleBookmark(int wordId) {
    final current = getStatus(wordId);
    setBookmark(wordId, !current.isBookmarked);
  }

  void setLearned(int wordId, bool value) {
    final current = getStatus(wordId);
    state = {
      ...state,
      wordId: current.copyWith(isLearned: value),
    };
  }

  void toggleLearned(int wordId) {
    final current = getStatus(wordId);
    setLearned(wordId, !current.isLearned);
  }

  void setHasNote(int wordId, bool value) {
    final current = getStatus(wordId);
    state = {
      ...state,
      wordId: current.copyWith(hasNote: value),
    };
  }

  void toggleHasNote(int wordId) {
    final current = getStatus(wordId);
    setHasNote(wordId, !current.hasNote);
  }
}

final wordStatusProvider =
    StateNotifierProvider<WordStatusViewModel, Map<int, WordStatus>>(
  (ref) => WordStatusViewModel(),
);

final wordStatusByIdProvider = Provider.family<WordStatus, int>((ref, wordId) {
  // 最小限の再ビルドにするためにselectで必要な要素のみ監視
  final status = ref.watch(
    wordStatusProvider.select((map) => map[wordId]),
  );
  return status ?? const WordStatus();
});

/////////
////
///
// 単語ごとのステータスボタン（学習済み/ブックマーク）
class StatusButtons extends ConsumerWidget {
  const StatusButtons({super.key, required this.wordId});
  final int wordId;

  static const Map<String, IconData> bookmarkIcon = {
    "true": Icons.bookmark_rounded,
    "false": Icons.bookmark_border_rounded,
    "added": Icons.bookmark_added_rounded,
  };

  static const Map<String, IconData> learnedIcon = {
    "true": Icons.check_circle_rounded,
    "false": Icons.check_circle_outline_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordStatus = ref.watch(wordStatusByIdProvider(wordId));
    final controller = ref.read(wordStatusProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyIconButton(
          iconSize: 22,
          defaultIcon: wordStatus.isLearned
              ? learnedIcon["true"] ?? Icons.error
              : learnedIcon["false"] ?? Icons.error,
          hoveredIcon: wordStatus.isLearned
              ? learnedIcon["true"] ?? Icons.error
              : learnedIcon["false"] ?? Icons.error,
          hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
          onTap: () {
            controller.toggleLearned(wordId);
          },
        ),
        const SizedBox(width: 3),
        MyIconButton(
          iconSize: 24,
          defaultIcon: wordStatus.isBookmarked
              ? bookmarkIcon["true"] ?? Icons.error
              : bookmarkIcon["false"] ?? Icons.error,
          hoveredIcon: wordStatus.isBookmarked
              ? bookmarkIcon["true"] ?? Icons.error
              : bookmarkIcon["false"] ?? Icons.error,
          hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
          onTap: () {
            controller.toggleBookmark(wordId);
          },
        ),
      ],
    );
  }
}
