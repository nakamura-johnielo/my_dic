import 'package:my_dic/features/ranking/port/model/ranking_part_of_speech.dart';

enum RankingStatusFilter { learned, bookmarked, hasNote }

/// Ranking 所有のフィルターおよびグループ化ポリシーの不変スナップショット。
final class RankingFilter {
  RankingFilter({
    Iterable<RankingPartOfSpeech> includedPartsOfSpeech = const [],
    Iterable<RankingPartOfSpeech> excludedPartsOfSpeech = const [],
    Iterable<RankingStatusFilter> includedStatuses = const [],
    Iterable<RankingStatusFilter> excludedStatuses = const [],
    this.groupByCatalogWord = false,
  })  : includedPartsOfSpeech = Set.unmodifiable(includedPartsOfSpeech),
        excludedPartsOfSpeech = Set.unmodifiable(excludedPartsOfSpeech),
        includedStatuses = Set.unmodifiable(includedStatuses),
        excludedStatuses = Set.unmodifiable(excludedStatuses);

  final Set<RankingPartOfSpeech> includedPartsOfSpeech;
  final Set<RankingPartOfSpeech> excludedPartsOfSpeech;
  final Set<RankingStatusFilter> includedStatuses;
  final Set<RankingStatusFilter> excludedStatuses;
  final bool groupByCatalogWord;

  @override
  bool operator ==(Object other) =>
      other is RankingFilter &&
      _sameSet(other.includedPartsOfSpeech, includedPartsOfSpeech) &&
      _sameSet(other.excludedPartsOfSpeech, excludedPartsOfSpeech) &&
      _sameSet(other.includedStatuses, includedStatuses) &&
      _sameSet(other.excludedStatuses, excludedStatuses) &&
      other.groupByCatalogWord == groupByCatalogWord;

  @override
  int get hashCode => Object.hash(
        _setHash(includedPartsOfSpeech),
        _setHash(excludedPartsOfSpeech),
        _setHash(includedStatuses),
        _setHash(excludedStatuses),
        groupByCatalogWord,
      );
}

bool _sameSet<T>(Set<T> left, Set<T> right) =>
    left.length == right.length && left.containsAll(right);

int _setHash<T>(Set<T> values) =>
    Object.hashAllUnordered(values);
