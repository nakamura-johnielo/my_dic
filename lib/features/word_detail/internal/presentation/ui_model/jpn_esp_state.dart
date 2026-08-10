import 'package:flutter/material.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/word_detail/port/word_detail_view_data.dart';

@immutable
class WordDetailState {
  const WordDetailState({this.detail = const QueryState.initial()});

  final QueryState<WordDetailViewData> detail;

  WordDetailState copyWith({QueryState<WordDetailViewData>? detail}) =>
      WordDetailState(detail: detail ?? this.detail);
}
