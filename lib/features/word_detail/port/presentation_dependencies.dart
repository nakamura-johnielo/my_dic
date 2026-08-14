import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// Presentation-only capabilities supplied by the application composition.
final class WordDetailPresentationDependencies {
  const WordDetailPresentationDependencies({
    required this.reader,
  });

  final WordDetailReaderPort reader;
}

final wordDetailPresentationDependenciesProvider =
    Provider<WordDetailPresentationDependencies>(
  (_) => throw StateError(
    'WordDetail presentation dependencies were not supplied.',
  ),
);
