import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/ranking/internal/presentation/provider/view_model_di.dart';

final rankingFilterEffectProvider = Provider.autoDispose
    .family<void, ({SessionScopeKey scope, VoidCallback resetPage})>(
  (ref, key) {
    ref.listen(
      rankingViewModelProvider(key.scope).select(
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
