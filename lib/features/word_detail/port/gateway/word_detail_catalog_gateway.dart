import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import 'package:my_dic/features/word_detail/port/model/word_detail_conjugation.dart';
import 'package:my_dic/features/word_detail/port/model/word_detail_data.dart';

/// コンシューマーの観点で表現した、WordDetail が必要とする Catalog 機能です。
abstract interface class WordDetailCatalogGateway {
  /// 必須の主要辞書集約を読み取ります。
  Future<Result<WordDetailDictionary>> readDictionary(CatalogWordRef word);

  /// 任意のスペイン語活用データを読み取ります。
  ///
  /// 成功時の `null` は、Catalog に [word] の活用がないことを意味します。
  /// プロバイダーの失敗は主要読み込みから独立しています。
  Future<Result<WordDetailConjugation?>> readConjugation(
    CatalogWordRef word,
  );
}
