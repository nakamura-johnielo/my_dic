import 'package:flutter/foundation.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

@immutable
final class WordDetailState {
  const WordDetailState({this.detail = const QueryState.initial()});

  final QueryState<WordDetailData> detail;

  WordDetailState copyWith({QueryState<WordDetailData>? detail}) =>
      WordDetailState(detail: detail ?? this.detail);
}
