import 'package:my_dic/features/word_detail/port/error/word_detail_read_error.dart';

/// A non-fatal failure retained alongside usable primary detail data.
sealed class WordDetailIssue {
  const WordDetailIssue({required this.error});

  final WordDetailReadError error;
}

/// Optional conjugation could not be loaded, but dictionary data is usable.
final class WordDetailConjugationIssue extends WordDetailIssue {
  const WordDetailConjugationIssue({required super.error});
}
