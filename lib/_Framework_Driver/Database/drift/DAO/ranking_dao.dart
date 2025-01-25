import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/i_enum.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/rankings.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/part_of_speech_lists.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/word_status.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
import 'package:tuple/tuple.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/ranking_dao.g.dart';

@DriftAccessor(tables: [Rankings, PartOfSpeechLists, WordStatus])
class RankingDao extends DatabaseAccessor<DatabaseProvider>
    with _$RankingDaoMixin {
  RankingDao(super.database);

  Future<Ranking?> getRankingById(int id) {
    return (select(rankings)..where((tbl) => tbl.rankingId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Ranking>?> getRankingListByPage(int page, int size) {
    return (select(rankings)
          ..limit(size, offset: size * page)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.rankingId)]))
        .get();
  }

  Future<List<Ranking>?> getFilteredRankingListByPage(
      int requiredPage,
      int size,
      Set<PartOfSpeech> partOfSpeechFilters,
      Set<FeatureTag> featureTagFilters) async {
    //where句生成
    final whereQuery = _getEqualsQuery(partOfSpeechFilters, "part_of_speech");

    //log("query: $whereQuery");
    final mainQuery = customSelect(
      '''
        with filtered_partofspeech as(
        select  min(part_of_speech_id) as part_of_speech_id ,part_of_speech,word_id
        from part_of_speech_lists 
        $whereQuery
        group by word_id
        order by part_of_speech_id asc
        )

        select r.* 
        from filtered_partofspeech f
        inner join rankings r on f.word_id = r.word_id
        order by r.ranking_no
        limit $size offset ${size * requiredPage};
      ''',
      //, f.part_of_speech_id,f.word_id,f.part_of_speech
      // 取得データrankingのみ
      readsFrom: {rankings, partOfSpeechLists},
    );

    final res = await mainQuery.get();
    /* if (res.isEmpty) {
      return null;
    } */

    for (int i = 0; i < 10; i++) {
      //log("raw word: ${res[i].read<String?>('word')}");
    }

    return res.map((row) {
      return Ranking(
        rankingId: row.read<int>('ranking_id'),
        rankingNo: row.read<int>('ranking_no'),
        word: row.read<String?>('word'),
        wordOrigin: row.read<String?>('word_origin'),
        wordId: row.read<int?>('word_id'),
      );
    }).toList();
  }

  // 結合クエリを使用して特定の単語に関連する例文を取得するメソッド
  Future<List<Tuple2<Ranking, WordStatusData>>?>
      getFilteredRankingWithStatusByPage(
          int requiredPage,
          int size,
          Set<PartOfSpeech> partOfSpeechFilters,
          Set<FeatureTag> featureTagFilters) async {
    //where句生成
    final whereQuery = _getEqualsQuery(partOfSpeechFilters, "part_of_speech");

    //log("query: $whereQuery");
    final mainQuery = customSelect(
      '''
        with rankingtable as(
            with filtered_partofspeech as(
            select  min(part_of_speech_id) as part_of_speech_id ,part_of_speech,word_id
            from part_of_speech_lists 
            $whereQuery
            group by word_id
            order by part_of_speech_id asc
            )

            select r.* 
            from filtered_partofspeech f
            inner join rankings r on f.word_id = r.word_id
            order by r.ranking_no
            limit $size offset ${size * requiredPage}
        )

        select *
        from rankingtable r
        left outer join word_status w on r.word_id=w.word_id
        order by r.ranking_no;
      ''',
      //, f.part_of_speech_id,f.word_id,f.part_of_speech
      // 取得データrankingのみ
      readsFrom: {rankings, partOfSpeechLists, wordStatus},
    );

    final res = await mainQuery.get();

    return res.map((row) {
      //final wordId = row.read<int>('word_id');
      final ranking = Ranking(
        rankingId: row.read<int>('ranking_id'),
        rankingNo: row.read<int>('ranking_no'),
        word: row.read<String?>('word'),
        wordOrigin: row.read<String?>('word_origin'),
        wordId: row.read<int?>('word_id'),
      );
      final status = WordStatusData(
        wordId: row.read<int?>('word_id') ?? -1,
        isLearned: row.read<int?>('is_learned'),
        isBookmarked: row.read<int?>('is_bookmarked'),
        hasNote: row.read<int?>('has_note'),
      );
      return Tuple2(ranking, status);
    }).toList();
  }

  /*   Future<List<Ranking>?> getRankingListByPage2(int page, int size) async {
  // 部分クエリ（サブクエリの代替）
  final subQuery = partOfSpeechLists.selectOnly()
    ..addColumns([
      partOfSpeechLists.partOfSpeechId.min(),
      partOfSpeechLists.partOfSpeech,
      partOfSpeechLists.wordId,
    ])
    ..where(
      partOfSpeechLists.partOfSpeech.isIn(['名詞', '略語']),
    )
    ..groupBy([partOfSpeechLists.wordId])
    ..orderBy([
      OrderingTerm.asc(partOfSpeechLists.partOfSpeechId.min())
    ]);

  final filteredPartOfSpeechLists = await subQuery.get();

  // メインクエリ
  final query = select(rankings).join([
    innerJoin(
      QueryAlias(
        subQuery.as('filtered'),
        alias: 'f',
      ),
      filteredPartOfSpeechLists.word   //subQuery.get()  .wordId.equalsExp(rankings.wordId),
    //subQuery.c[partOfSpeechLists.wordId].equalsExp(rankings.wordId),
    ),
  ])
    ..orderBy([
      OrderingTerm.asc(rankings.wordId)
    ]);


  // クエリ結果を取得
  final results = await query.get();

    return (select(rankings)
          ..limit(size, offset: size * page)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.rankingId)]))
        .get();
  }

   Future<List<Ranking>?> getRankingListByPageWithFilter(
      int page, int size, filters) {
    // クエリの定義

    final subqueryRanking = select(rankings)
      ..where((tbl) => tbl.rankingNo.isBetweenValues(page, size));

    final subqueryHinshi = selectOnly(partOfSpeechLists, distinct: true)
                            ..addColumns([partOfSpeechLists.wordId.min(), partOfSpeechLists.partOfSpeech])
                            ..groupBy([partOfSpeechLists.wordId]);

final query = subqueryRanking.join([
  leftOuterJoin(subqueryHinshi, subqueryHinshi.wordId.equalsExp(rankings.wordId))
]);

final result = await query.get();

    return (select(rankings)
          ..limit(size, offset: size * page)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.rankingId)]))
        .get();
  }
 */
}

String _getEqualsQuery(Set<DisplayEnumMixin> data, String colName) {
  String res = "where";
  if (data.isEmpty) {
    return "";
  }
  /* for (int i = 0; i < data.length; i++) {
    if (i > 0) {
      res = "$res or ";
    }
    res = "$res part_of_speech = '${data[i].japName}'";
  } */

  bool first = true;
  for (var partOfSpeech in data) {
    if (!first) {
      res = "$res or ";
    }
    res = "$res $colName = '${partOfSpeech.display}'";
    first = false;
  }
  return res;
}
