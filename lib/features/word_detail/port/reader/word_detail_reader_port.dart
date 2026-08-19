import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_detail/port/result/word_detail_result.dart';
import 'package:my_dic/features/word_detail/port/word_detail_query.dart';

/// 完全な WordDetail 投影用の読み取り専用アプリケーション機能です。
abstract interface class WordDetailQueryPort {
  Future<Result<WordDetailResult>> read(WordDetailQuery query);
}
