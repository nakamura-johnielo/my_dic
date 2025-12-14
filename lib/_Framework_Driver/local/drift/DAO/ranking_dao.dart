import 'package:drift/drift.dart';
import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/i_enum.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/core/infrastructure/database/table/conjugations.dart';
import 'package:my_dic/_Framework_Driver/local/drift/Entity/rankings.dart';
import 'package:my_dic/_Framework_Driver/local/drift/Entity/part_of_speech_lists.dart';
import 'package:my_dic/core/infrastructure/database/table/word_status.dart';
import 'package:my_dic/_Framework_Driver/local/drift/database_provider.dart';
import 'package:tuple/tuple.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/ranking_dao.g.dart';

@DriftAccessor(tables: [Rankings, PartOfSpeechLists, WordStatus, Conjugations])
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
          Set<FeatureTag> featureTagFilters,
          Set<PartOfSpeech> partOfSpeechExcludeFilters,
          Set<FeatureTag> featureTagExcludeFilters) async {
    //where句生成
    final speechWhereQuery = _getWhereQuery(
        partOfSpeechFilters, partOfSpeechExcludeFilters, "part_of_speech");

    final bool multiLemmaHidden =
        featureTagFilters.contains(FeatureTag.multiLemma) ? true : false;
    featureTagFilters.remove(FeatureTag.multiLemma);
    final featureWhereQuery = _getWhereQueryWordStatus(
        featureTagFilters, featureTagExcludeFilters, "part_of_speech");

    //log("query: $whereQuery");
    final mainQuery = customSelect(
      '''
        with rankingtable as(  
            with rankingtable as(
                with filtered_partofspeech as(
                select  min(part_of_speech_id) as part_of_speech_id ,part_of_speech,word_id
                from part_of_speech_lists 
                $speechWhereQuery
                group by word_id
                
                )

                select r.* 
                from filtered_partofspeech f
                inner join rankings r on f.word_id = r.word_id
                
            )

            select r.*, w.word_id as w_word_id,w.is_learned,w.is_bookmarked,w.has_note
            from rankingtable r
            inner join 
            ( $featureWhereQuery
            ) w 
            on r.word_id=w.word_id
            
        )

        select r.ranking_id , 
                ${multiLemmaHidden ? "min (r.ranking_no) as ranking_no" : "r.ranking_no"}  , 
                r.word, 
                r.word_origin, 
                r.word_id, 
                r.w_word_id, 
                r.is_learned, 
                r.is_bookmarked, 
                r.has_note,
                CASE 
                  WHEN EXISTS (SELECT 1 FROM conjugations c WHERE c.word_id = r.word_id)
                  THEN 1 ELSE 0 
                END AS has_conj
        from rankingtable r
        ${multiLemmaHidden ? "group by r.word_id" : ""}
        order by r.ranking_no

                limit $size offset ${size * requiredPage}
      ''',
      //, f.part_of_speech_id,f.word_id,f.part_of_speech
      // 取得データrankingのみ
      readsFrom: {rankings, partOfSpeechLists, wordStatus, conjugations},
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
        hasConj: row.read<int>('has_conj'),
      );
      final status = WordStatusData(
        wordId: row.read<int?>('w_word_id') ?? -1,
        isLearned: row.read<int?>('is_learned'),
        isBookmarked: row.read<int?>('is_bookmarked'),
        hasNote: row.read<int?>('has_note'),
        editAt: '',
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
  String res = "";
  if (data.isEmpty) {
    return "";
  }

  bool first = true;
  for (var d in data) {
    if (!first) {
      res = "$res or ";
    }
    res = "$res $colName = '${d.display}'";
    first = false;
  }
  return res;
}

String _getExcludeQuery(Set<DisplayEnumMixin> data, String colName) {
  if (data.isEmpty) {
    return "";
  }

  String res = """
  word_id NOT IN (
    SELECT word_id
    FROM part_of_speech_lists
    WHERE ${_getEqualsQuery(data, colName)}
  )
  """;
  return res;
}

String _getEqualsQueryWordStatus(Set<DisplayEnumMixin> data) {
  String res = "";
  if (data.isEmpty) {
    return "";
  }

  bool first = true;
  for (var d in data) {
    if (!first) {
      res = "$res or ";
    }
    res = "$res ${d.dbColName} = 1 ";
    first = false;
  }
  return res;
}

String _getWhereQuery(Set<DisplayEnumMixin> filter,
    Set<DisplayEnumMixin> excludeFilter, String colName) {
  String res = "where";

  if (filter.isEmpty && excludeFilter.isEmpty) {
    return "";
  }

  String where = _getEqualsQuery(filter, colName);
  String notWhere = _getExcludeQuery(excludeFilter, colName);
  if (filter.isNotEmpty && excludeFilter.isNotEmpty) {
    res = "$res ($where) and $notWhere";
    return res;
  }
  res = "$res $where $notWhere";
  return res;
}

String _getExcludeQueryWordStatus(Set<DisplayEnumMixin> data) {
  if (data.isEmpty) {
    return "";
  }

  String res = """
  word_id NOT IN (
    SELECT word_id
    FROM word_status
    WHERE ${_getEqualsQueryWordStatus(data)}
  )
  """;
  return res;
}

String _getWhereQueryWordStatus(Set<DisplayEnumMixin> filter,
    Set<DisplayEnumMixin> excludeFilter, String colName) {
  String res = "select  * from word_status";

  if (filter.isEmpty && excludeFilter.isEmpty) {
    return res;
  }
  res = "$res where ";
  String where = _getEqualsQueryWordStatus(filter);
  String notWhere = _getExcludeQueryWordStatus(excludeFilter);
  if (filter.isNotEmpty && excludeFilter.isNotEmpty) {
    res = "$res ($where) and $notWhere";
    return res;
  }
  res = "$res $where $notWhere";
  return res;
}
