// フィルタ/ページネーションが変わったら、UI側のスクロールを reset
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/di/view_model_di.dart';

// final rankingFilterEffectProvider = Provider<void>((ref) {
//   ref.listen(
//     rankingViewModelProvider.select(
//       (s) => (s.partOfSpeechFilters, s.featureTagFilters, s.pagenationFilter),
//     ),
//     (prev, next) {
//       if (prev == null) return; // 初回は無視
//        if (!mounted) return;
//       if (prev != next) {
//         resetPage();
//       }
//     },
//   );
// });

final rankingFilterEffectProvider =
    Provider.autoDispose.family<void, VoidCallback>((ref, resetPage) {
  ref.listen(
    rankingViewModelProvider.select(
      (s) => (s.partOfSpeechFilters, s.featureTagFilters, s.pagenationFilter),
    ),
    (prev, next) {
      // 初回通知は無視（初期化直後に reset しない）
      if (prev == null) return;

      // Provider内では mounted ではなく ref.mounted を使う
      //if (!ref.mounted) return;

      if (prev != next) {
        resetPage();
      }
    },
  );
});