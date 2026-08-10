import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_detail/port/word_detail_query.dart';
import 'package:my_dic/features/word_detail/port/word_detail_query_result.dart';

/// Application boundary for loading a complete word-detail projection.
abstract interface class ILoadWordDetailQuery {
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query);
}
