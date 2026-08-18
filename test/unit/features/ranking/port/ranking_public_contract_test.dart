import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

void main() {
  group('Ranking public contract', () {
    test('validates page, size, account scope, and item identity', () {
      expect(
        () => RankingPageQuery(
          page: -1,
          size: 1,
          scope: const RankingAccountScope.guest(),
        ),
        throwsArgumentError,
      );
      expect(
        () => RankingPageQuery(
          page: 0,
          size: 0,
          scope: const RankingAccountScope.guest(),
        ),
        throwsArgumentError,
      );
      expect(() => RankingAccountScope.account('  '), throwsArgumentError);
      expect(() => RankingItemId.fromSerialized(0), throwsArgumentError);
    });

    test('filter collections are defensive and have value equality', () {
      final parts = <RankingPartOfSpeech>{RankingPartOfSpeech.noun};
      final statuses = <RankingStatusFilter>{RankingStatusFilter.learned};
      final filter = RankingFilter(
        includedPartsOfSpeech: parts,
        excludedStatuses: statuses,
        groupByCatalogWord: true,
      );
      parts.add(RankingPartOfSpeech.verb);
      statuses.clear();

      expect(filter.includedPartsOfSpeech, {RankingPartOfSpeech.noun});
      expect(filter.excludedStatuses, {RankingStatusFilter.learned});
      expect(
        filter,
        RankingFilter(
          includedPartsOfSpeech: {RankingPartOfSpeech.noun},
          excludedStatuses: {RankingStatusFilter.learned},
          groupByCatalogWord: true,
        ),
      );
      expect(
        () => filter.includedPartsOfSpeech.add(RankingPartOfSpeech.verb),
        throwsUnsupportedError,
      );
    });

    test('page and gateway batches own immutable collection snapshots', () {
      final items = [_item(1)];
      final page = RankingPage(items: items, hasMore: false);
      final queryWords = [_word(1), _word(1), _word(2)];
      final query = RankingWordStatusBatchQuery(
        scope: const RankingAccountScope.guest(),
        words: queryWords,
      );
      items.clear();
      queryWords.clear();

      expect(page.items, hasLength(1));
      expect(query.words, [_word(1), _word(2)]);
      expect(() => page.items.clear(), throwsUnsupportedError);
    });

    test('absence is an empty success page and a missing batch key', () async {
      final result = await _EmptyReader().readPage(
        RankingPageQuery(
          page: 0,
          size: 10,
          scope: const RankingAccountScope.guest(),
        ),
      );
      final batch = RankingWordStatusBatch.empty();

      expect(result.dataOrNull?.items, isEmpty);
      expect(result.dataOrNull?.hasMore, isFalse);
      expect(batch.statusFor(_word(1)), isNull);
    });

    test('business facade and its exported contracts stay pure Dart', () {
      final files = Directory('lib/features/ranking/port')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where((file) => !file.path.endsWith('presentation_entry.dart'))
          .where(
            (file) => !file.path.endsWith('presentation_dependencies.dart'),
          );
      final source = files.map((file) => file.readAsStringSync()).join('\n');
      final facade =
          File('lib/features/ranking/port/ranking.dart').readAsStringSync();

      expect(source, isNot(contains("package:flutter/")));
      expect(source, isNot(contains('package:flutter_riverpod/')));
      expect(source, isNot(contains('package:drift/')));
      expect(facade, isNot(contains('ranking_query.dart')));
      expect(facade, isNot(contains('update_ranking_filter')));
      expect(facade, isNot(contains('ranking_query_repository.dart')));
    });
  });
}

CatalogWordRef _word(int id) => CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: id,
    );

RankingItem _item(int id) => RankingItem(
      id: RankingItemId.fromSerialized(id),
      word: _word(id),
      rank: id,
      rankedWord: 'word $id',
      lemma: 'lemma $id',
      hasConjugation: false,
    );

final class _EmptyReader implements RankingPageQueryPort {
  @override
  Future<Result<RankingPage>> readPage(RankingPageQuery query) async =>
      Result.success(RankingPage(items: const [], hasMore: false));
}
