import 'dart:collection';

import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/port/model/word_status.dart';

/// Complete status facts for every distinct word in a batch query.
final class WordStatusBatch {
  WordStatusBatch(Iterable<WordStatus> statuses)
      : _byWord = Map.unmodifiable({
          for (final status in statuses) status.word: status,
        });

  WordStatusBatch.empty() : _byWord = const {};

  final Map<CatalogWordRef, WordStatus> _byWord;

  Map<CatalogWordRef, WordStatus> get byWord =>
      UnmodifiableMapView(_byWord);

  List<WordStatus> get statuses =>
      List.unmodifiable(_byWord.values);

  WordStatus? statusFor(CatalogWordRef word) => _byWord[word];

  bool get isEmpty => _byWord.isEmpty;
}
