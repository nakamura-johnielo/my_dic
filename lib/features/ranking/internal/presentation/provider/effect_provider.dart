import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/internal/presentation/provider/view_model_di.dart';

final rankingFilterEffectProvider = Provider.autoDispose
    .family<void, ({RankingPresentationKey key, VoidCallback resetPage})>(
  (ref, key) {
    ref.listen(
      rankingViewModelProvider(key.key).select(
        (state) => (
          filter: state.filter,
          paginationFilter: state.pagenationFilter,
        ),
      ),
      (previous, next) {
        if (previous != null && previous != next) key.resetPage();
      },
    );
  },
);
