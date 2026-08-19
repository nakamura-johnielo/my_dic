import 'dart:collection';

import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/port/model/word_status.dart';

/// バッチクエリ内の各重複しない単語に対する完全なステータス情報です。
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
