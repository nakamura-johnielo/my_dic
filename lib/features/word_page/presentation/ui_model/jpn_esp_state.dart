import 'package:flutter/material.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_view_data.dart';

@immutable
class WordPageState {
  const WordPageState({this.detail = const QueryState.initial()});

  final QueryState<WordDetailViewData> detail;

  WordPageState copyWith({QueryState<WordDetailViewData>? detail}) =>
      WordPageState(detail: detail ?? this.detail);
}
