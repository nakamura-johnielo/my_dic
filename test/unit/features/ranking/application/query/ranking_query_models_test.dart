import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/application/query/i_ranking_query_repository.dart';
import 'package:my_dic/features/ranking/application/query/ranking_list_item.dart';
import 'package:my_dic/features/ranking/application/query/ranking_page.dart';
import 'package:my_dic/features/ranking/application/query/ranking_query.dart';

void main() {
  group('Ranking query models', () {
    test('RankingQuery defensively copies every filter set', () {
      final includedPartOfSpeech = {CatalogPartOfSpeech.noun};
      final excludedPartOfSpeech = {CatalogPartOfSpeech.verb};
      final includedFeatureTags = {FeatureTag.isLearned};
      final excludedFeatureTags = {FeatureTag.hasNote};

      final query = RankingQuery(
        page: 0,
        size: 20,
        accountId: 'account-1',
        includedPartOfSpeech: includedPartOfSpeech,
        excludedPartOfSpeech: excludedPartOfSpeech,
        includedFeatureTags: includedFeatureTags,
        excludedFeatureTags: excludedFeatureTags,
      );
      includedPartOfSpeech.add(CatalogPartOfSpeech.adjective);
      excludedPartOfSpeech.clear();
      includedFeatureTags.add(FeatureTag.hasNote);
      excludedFeatureTags.clear();

      expect(query.includedPartOfSpeech, {CatalogPartOfSpeech.noun});
      expect(query.excludedPartOfSpeech, {CatalogPartOfSpeech.verb});
      expect(query.includedFeatureTags, {FeatureTag.isLearned});
      expect(query.excludedFeatureTags, {FeatureTag.hasNote});
      expect(() => query.includedPartOfSpeech.add(CatalogPartOfSpeech.adverb),
          throwsUnsupportedError);
    });

    test('RankingQuery accepts only a zero-based page and positive size', () {
      expect(
        () => RankingQuery(page: -1, size: 1, accountId: 'account-1'),
        throwsArgumentError,
      );
      expect(
        () => RankingQuery(page: 0, size: 0, accountId: 'account-1'),
        throwsArgumentError,
      );
      expect(
        () => RankingQuery(page: 0, size: 1, accountId: ''),
        throwsArgumentError,
      );
    });

    test('rejects MyWord because Ranking has no MyWord read projection', () {
      expect(
        () => RankingQuery(
          page: 0,
          size: 1,
          accountId: 'account-1',
          includedFeatureTags: {FeatureTag.myWord},
        ),
        throwsArgumentError,
      );
    });

    test('RankingPage defensively copies items', () {
      final source = [_item];
      final page = RankingPage(items: source, hasNext: true);
      source.clear();

      expect(page.items, [_item]);
      expect(() => page.items.add(_item), throwsUnsupportedError);
    });

    test('query port returns the shared Result type', () async {
      final result = await _SuccessRepository().fetchPage(
        RankingQuery(page: 0, size: 1, accountId: 'account-1'),
      );

      expect(result, isA<Result<RankingPage>>());
      expect(result.dataOrNull?.items, [_item]);
    });

    test('query source files do not import framework or Drift packages', () {
      final directory = Directory('lib/features/ranking/application/query');
      final imports = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync())
          .join('\n');

      expect(imports, isNot(contains("package:flutter/")));
      expect(imports, isNot(contains('package:flutter_riverpod/')));
      expect(imports, isNot(contains('package:drift/')));
    });

    test('ranking keeps status as a live UI projection, not a page snapshot',
        () {
      final rankingFiles = Directory('lib/features/ranking')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync())
          .join('\n');
      final listItem = File(
        'lib/features/ranking/application/query/ranking_list_item.dart',
      ).readAsStringSync();

      expect(listItem, isNot(contains('isLearned')));
      expect(listItem, isNot(contains('isBookmarked')));
      expect(listItem, isNot(contains('hasNote')));
      expect(rankingFiles, isNot(contains('features/word_status/internal')));
      expect(rankingFiles, isNot(contains('WordStatusDao')));
      expect(rankingFiles, isNot(contains('WordStatusLocalStore')));
      expect(rankingFiles, isNot(contains('WordStatusDatasetAdapter')));
      expect(rankingFiles, isNot(contains('SyncDataset')));
    });
  });
}

const _item = RankingListItem(
  rank: 1,
  rankedWord: 'ser',
  lemma: 'ser',
  wordId: 1,
  hasConjugation: true,
);

class _SuccessRepository implements IRankingQueryRepository {
  @override
  Future<Result<RankingPage>> fetchPage(RankingQuery query) async {
    return Result.success(RankingPage(items: [_item], hasNext: false));
  }
}
