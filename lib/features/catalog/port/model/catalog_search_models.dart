import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_frequency_level.dart';

final class CatalogWordSearchHit {
  const CatalogWordSearchHit({
    required this.word,
    required this.headword,
    required this.hasConjugation,
  });

  final CatalogWordRef word;
  final String headword;
  final bool hasConjugation;

  @override
  bool operator ==(Object other) =>
      other is CatalogWordSearchHit &&
      word == other.word &&
      headword == other.headword &&
      hasConjugation == other.hasConjugation;

  @override
  int get hashCode => Object.hash(word, headword, hasConjugation);
}

final class CatalogConjugationSearchHit {
  CatalogConjugationSearchHit({
    required this.word,
    required this.headword,
    required Map<CatalogConjugationMatch, String> matches,
  }) : matches = Map.unmodifiable(matches);

  final CatalogWordRef word;
  final String headword;
  final Map<CatalogConjugationMatch, String> matches;

  @override
  bool operator ==(Object other) =>
      other is CatalogConjugationSearchHit &&
      word == other.word &&
      headword == other.headword &&
      _mapEquals(matches, other.matches);

  @override
  int get hashCode => Object.hash(word, headword, _mapHash(matches));
}

/// Catalog の活用形テーブル内における型付けされた位置。
final class CatalogConjugationMatch {
  const CatalogConjugationMatch({required this.moodTense, this.subject});

  final CatalogMoodTense moodTense;
  final CatalogSubject? subject;

  @override
  bool operator ==(Object other) =>
      other is CatalogConjugationMatch &&
      moodTense == other.moodTense &&
      subject == other.subject;

  @override
  int get hashCode => Object.hash(moodTense, subject);
}

final class CatalogMeaningSummary {
  const CatalogMeaningSummary({required this.meaning});

  final String meaning;

  @override
  bool operator ==(Object other) =>
      other is CatalogMeaningSummary && meaning == other.meaning;

  @override
  int get hashCode => meaning.hashCode;
}

final class CatalogHeadwordMetadata {
  const CatalogHeadwordMetadata({
    required this.headword,
    required this.frequencyLevel,
  });

  final String headword;
  final CatalogFrequencyLevel frequencyLevel;

  @override
  bool operator ==(Object other) =>
      other is CatalogHeadwordMetadata &&
      headword == other.headword &&
      frequencyLevel == other.frequencyLevel;

  @override
  int get hashCode => Object.hash(headword, frequencyLevel);
}

final class CatalogRankingMetadata {
  const CatalogRankingMetadata({required this.rankingNo});

  final int rankingNo;

  @override
  bool operator ==(Object other) =>
      other is CatalogRankingMetadata && rankingNo == other.rankingNo;

  @override
  int get hashCode => rankingNo.hashCode;
}

bool _mapEquals<K, V>(Map<K, V> first, Map<K, V> second) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  for (final entry in first.entries) {
    if (second[entry.key] != entry.value) return false;
  }
  return true;
}

int _mapHash<K, V>(Map<K, V> map) => Object.hashAllUnordered(
      map.entries.map((entry) => Object.hash(entry.key, entry.value)),
    );
