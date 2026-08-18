import 'dart:collection';

import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/port/model/word_status.dart';
import 'package:my_dic/features/word_status/port/model/word_status_scope.dart';
import 'package:my_dic/features/word_status/port/result.dart';

final class ReadWordStatusQuery {
  const ReadWordStatusQuery({required this.scope, required this.word});

  final WordStatusScope scope;
  final CatalogWordRef word;
}

/// A batch of WordStatus facts.
///
/// Duplicate words are collapsed while preserving their first input order.
/// An empty batch is valid and returns an empty success result.
final class ReadWordStatusBatchQuery {
  ReadWordStatusBatchQuery({
    required this.scope,
    required Iterable<CatalogWordRef> words,
  }) : words = List.unmodifiable(LinkedHashSet<CatalogWordRef>.of(words));

  final WordStatusScope scope;
  final List<CatalogWordRef> words;
}

abstract interface class WordStatusReaderPort {
  Future<Result<WordStatus>> read(ReadWordStatusQuery query);
}

abstract interface class WordStatusWatchPort {
  Stream<Result<WordStatus>> watch(ReadWordStatusQuery query);
}

abstract interface class WordStatusBatchReaderPort {
  Future<Result<WordStatusBatch>> readBatch(ReadWordStatusBatchQuery query);
}
