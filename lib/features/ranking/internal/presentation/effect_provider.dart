// フィルタ/ページネーションが変わったら、UI側のスクロールを reset
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/internal/composition/view_model_di.dart';
import 'package:my_dic/core/session/session_scope_key.dart';

final rankingFilterEffectProvider = Provider.autoDispose
    .family<void, ({SessionScopeKey scope, VoidCallback resetPage})>(
        (ref, key) {
  ref.listen(
    rankingViewModelProvider(key.scope).select(
      (s) => (s.partOfSpeechFilters, s.featureTagFilters, s.pagenationFilter),
    ),
    (prev, next) {
      // 初回通知は無視（初期化直後に reset しない）
      if (prev == null) return;

      if (prev != next) {
        key.resetPage();
      }
    },
  );
});
