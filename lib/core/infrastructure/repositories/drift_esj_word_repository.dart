import 'package:my_dic/core/infrastructure/datasource/conjugacion/i_conjugacion_local_datasource.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_dictionary_data_source.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_word_data_source.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/esj_word_converter.dart';
import 'package:my_dic/features/ranking/data/data_source/local/i_ranking_local_data_source.dart';

class EsjWordRepository implements IEsjWordRepository {
  final IEsjWordLocalDataSource _wordDataSource;
  final IEsjDictionaryLocalDataSource _dictionaryDataSource;
  final IConjugacionLocalDataSource _conjugacionDataSource;
  final IRankingLocalDataSource _rankingLocalDataSource;
  EsjWordRepository(this._wordDataSource, this._dictionaryDataSource,
      this._conjugacionDataSource, this._rankingLocalDataSource);

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWord(String word) async {
    try {
      final tableDataList = await _wordDataSource.getWordsByWord(word);
      final entities = EsjWordConverter.toEntityList(tableDataList);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語の検索に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz) async {
    try {
      final tableDataList = await _wordDataSource.getWordsByWordByPage(
          word, size, currentPage, forQuiz);
      final entities = EsjWordConverter.toEntityList(tableDataList);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語リストの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<EspJpnWord>>> getQuizWordsByWordByPage(
      String word, int size, int currentPage) async {
    try {
      final tableDataList = await _wordDataSource.getQuizWordsByWordByPage(
          word, size, currentPage);
      final entities = EsjWordConverter.toEntityList(tableDataList);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'クイズ用単語リストの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<String>> getSimpleMeaningById(int id) async {
    final meaningConj = await _conjugacionDataSource.getSimpleMeaningById(id);
    if (meaningConj != null) {
      return Result.success(meaningConj);
    }

    final meaningDic = await _dictionaryDataSource.getFirstContentByWordId(id);

    if (meaningDic != null) {
      return Result.success(_convert1line(meaningDic));
    } else {
      return Result.failure(DatabaseError(
        message: '簡単な意味の取得に失敗しました',
      ));
    }
  }

  @override
  Future<Result<int>> getStarCountById(int id) async {
    final headword = await _dictionaryDataSource.getFirstHeadwordByWordId(id);
    if (headword == null) return Result.success(0);

    // 正規表現パターン
    final pattern = RegExp(r'<sup>(\*+)</sup>');

    final match = pattern.firstMatch(headword);

    if (match != null) {
      String stars = match.group(1)!; // "***"
      return Result.success(stars.length);
    }
    return Result.success(0);
  }

  
  @override
  Future<Result<int>> getRankingNoById(int id)async {
    final rankingNo =await _rankingLocalDataSource.getRankingNoByWordId(id);
    if(rankingNo != null){
      return Result.success(rankingNo);
    }else{
      return Result.failure(NotFoundError(
        message: 'ランキング順位の取得に失敗しました',
      ));
    }
  }

  @override
  Future<Result<Map<int, int>>> getStarCountsByWordIds(List<int> wordIds) async {
    try {
      if (wordIds.isEmpty) return Result.success({});

      final headwords = await _dictionaryDataSource.getFirstHeadwordsByWordIds(wordIds);
      final pattern = RegExp(r'<sup>(\*+)</sup>');

      final res = <int, int>{};
      headwords.forEach((wordId, headword) {
        final match = pattern.firstMatch(headword);
        if (match == null) {
          res[wordId] = 0;
          return;
        }
        res[wordId] = match.group(1)!.length;
      });
      return Result.success(res);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'スター数の取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<Map<int, String>>> getSimpleMeaningsByWordIds(
      List<int> wordIds) async {
    try {
      if (wordIds.isEmpty) return Result.success({});

      final conjMeanings = await _conjugacionDataSource.getMeaningsByWordIds(wordIds);
      final dicHtmls = await _dictionaryDataSource.getFirstContentsByWordIds(wordIds);

      final res = <int, String>{};

      // conj first
      res.addAll(conjMeanings);

      // fill from dictionary
      dicHtmls.forEach((wordId, html) {
        if (res.containsKey(wordId)) return;
        final converted = _convert1line(html);
        if (converted.isEmpty) return;
        res[wordId] = converted;
      });

      return Result.success(res);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '簡単な意味の取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<Map<int, int>>> getRankingNosByWordIds(List<int> wordIds) async {
    try {
      if (wordIds.isEmpty) return Result.success({});
      final res = await _rankingLocalDataSource.getRankingNosByWordIds(wordIds);
      return Result.success(res);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ランキング順位の取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }



  //======local method=================================================================
  String _convert1line(String text) {
// 正規表現で <p data-orgtag="meaning" ...>...</p> を抽出
    final pattern =
        RegExp(r'<p data-orgtag="meaning"[^>]*>(.*?)<\/p>', dotAll: true);
    final matches = pattern.allMatches(text);
    String meanings = "";
    for (final m in matches) {
      String text = m.group(1)!;
      // さらにタグを除去（bタグなど）
      text = text.replaceAll(RegExp(r'<[^>]+>'), '');
      meanings += text + "  ";
      if (meanings.length > UIConsts.oneLineMeaningMaxLength) {
        meanings = meanings.substring(0, UIConsts.oneLineMeaningMaxLength);
        break;
      }
    }

    return meanings; // 例: ['[女] ［複～es, ～s］', '1 スペイン語字母の第1字；a の名称．', '2 〖音楽〗']
  }
}
