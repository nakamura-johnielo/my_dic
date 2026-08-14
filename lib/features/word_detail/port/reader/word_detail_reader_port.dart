import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_detail/port/result/word_detail_result.dart';
import 'package:my_dic/features/word_detail/port/word_detail_query.dart';

/// Read-only application capability for a complete WordDetail projection.
abstract interface class WordDetailReaderPort {
  Future<Result<WordDetailResult>> read(WordDetailQuery query);
}
