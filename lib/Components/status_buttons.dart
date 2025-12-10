import 'package:flutter_riverpod/flutter_riverpod.dart';
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/button/my_icon_button.dart';
import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/Usecase/esp_jpn_status/esp_jpn_status_interactor.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word_status.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/user/profile.dart';
//import 'package:my_dic/_Interface_Adapter/Controller/word_status_controller.dart';

// @immutable
// class WordStatus {
//   final bool isBookmarked;
//   final bool isLearned;
//   final bool hasNote;

//   const WordStatus({
//     this.isBookmarked = false,
//     this.isLearned = false,
//     this.hasNote = false,
//   });

//   WordStatus copyWith({
//     bool? isBookmarked,
//     bool? isLearned,
//     bool? hasNote,
//   }) {
//     return WordStatus(
//       isBookmarked: isBookmarked ?? this.isBookmarked,
//       isLearned: isLearned ?? this.isLearned,
//       hasNote: hasNote ?? this.hasNote,
//     );
//   }
// }

class WordStatusViewModel extends StateNotifier<Map<int, WordStatus>> {
  WordStatusViewModel(this._espJpnStatusInteractor, this._updateInteractor)
      : super(const {});
  final EspJpnStatusInteractor _espJpnStatusInteractor;
  final EspJpnStatusUpdateInteractor _updateInteractor;

  WordStatus getStatus(int wordId) =>
      state[wordId] ?? WordStatus(wordId: wordId);

  Future<void> init(int wordId) async {
    if (state[wordId] == null) await fetchStatus(wordId);
  }

  Future<void> fetchStatus(int wordId) async {
    final status = await _espJpnStatusInteractor.fetchWordStatus(wordId);
    state = {...state, wordId: status};
  }

  void setBookmark(int wordId, bool value, String userId) {
    final current = getStatus(wordId);
    state = {
      ...state,
      wordId: current.copyWith(isBookmarked: value),
    };
    _updateInteractor.execute(
      EsJUpdateStatusInputData(
        userId,
        wordId,
        {
          if (value) FeatureTag.isBookmarked,
          if (state[wordId]?.hasNote ?? false) FeatureTag.hasNote,
          if (state[wordId]?.isLearned ?? false) FeatureTag.isLearned,
        },
      ),
    );
  }

  void toggleBookmark(int wordId, String userId) {
    final current = getStatus(wordId);
    setBookmark(wordId, !current.isBookmarked, userId);
  }

  void setLearned(int wordId, bool value, String userId) {
    final current = getStatus(wordId);
    state = {
      ...state,
      wordId: current.copyWith(isLearned: value),
    };
    _updateInteractor.execute(
      EsJUpdateStatusInputData(
        userId,
        wordId,
        {
          if (state[wordId]?.isBookmarked ?? false) FeatureTag.isBookmarked,
          if (state[wordId]?.hasNote ?? false) FeatureTag.hasNote,
          if (value) FeatureTag.isLearned,
        },
      ),
    );
  }

  void toggleLearned(int wordId, String userId) {
    final current = getStatus(wordId);
    setLearned(wordId, !current.isLearned, userId);
  }

  void setHasNote(int wordId, bool value, String userId) {
    final current = getStatus(wordId);
    state = {
      ...state,
      wordId: current.copyWith(hasNote: value),
    };
    _updateInteractor.execute(
      EsJUpdateStatusInputData(
        userId,
        wordId,
        {
          if (state[wordId]?.isBookmarked ?? false) FeatureTag.isBookmarked,
          if (value) FeatureTag.hasNote,
          if (state[wordId]?.isLearned ?? false) FeatureTag.isLearned,
        },
      ),
    );
  }

  void toggleHasNote(int wordId, String userId) {
    final current = getStatus(wordId);
    setHasNote(wordId, !current.hasNote, userId);
  }
}

// final wordStatusViewModelProvider =
//     StateNotifierProvider<WordStatusViewModel, Map<int, WordStatus>>(
//   (ref) => WordStatusViewModel(EspJpnStatusInteractor),
// );

// final wordStatusByIdProvider = Provider.family<WordStatus?, int>((ref, wordId) {
//   // 最小限の再ビルドにするためにselectで必要な要素のみ監視
//   final status = ref.watch(
//     wordStatusViewModelProvider.select((map) => map[wordId]),
//   );
//   return status; //?? const WordStatus();
// });

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
    final controller = ref.read(wordStatusViewModelProvider.notifier);
    controller.init(wordId); //初期化

    final userId = ref.watch(userViewModelProvider)?.id ?? "anonymous";

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyIconButton(
          iconSize: 22,
          defaultIcon: wordStatus?.isLearned ?? false
              ? learnedIcon["true"] ?? Icons.error
              : learnedIcon["false"] ?? Icons.error,
          hoveredIcon: wordStatus?.isLearned ?? false
              ? learnedIcon["true"] ?? Icons.error
              : learnedIcon["false"] ?? Icons.error,
          hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
          onTap: () {
            controller.toggleLearned(wordId, userId);
          },
        ),
        const SizedBox(width: 3),
        MyIconButton(
          iconSize: 24,
          defaultIcon: wordStatus?.isBookmarked ?? false
              ? bookmarkIcon["true"] ?? Icons.error
              : bookmarkIcon["false"] ?? Icons.error,
          hoveredIcon: wordStatus?.isBookmarked ?? false
              ? bookmarkIcon["true"] ?? Icons.error
              : bookmarkIcon["false"] ?? Icons.error,
          hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
          onTap: () {
            controller.toggleBookmark(wordId, userId);
          },
        ),
      ],
    );
  }
}
