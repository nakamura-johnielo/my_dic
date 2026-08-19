import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// 1 つのアプリケーションスコープに提供される完全な WordDetail 機能です。
final class WordDetailPorts {
  const WordDetailPorts({required this.reader});

  final WordDetailQueryPort reader;
}
