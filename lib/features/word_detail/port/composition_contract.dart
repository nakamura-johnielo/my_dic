import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// Complete WordDetail capabilities supplied to one application scope.
final class WordDetailPorts {
  const WordDetailPorts({required this.reader});

  final WordDetailReaderPort reader;
}
