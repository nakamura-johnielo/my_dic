/// 活用候補の互換性上限です。
abstract final class SearchSuggestionPolicy {
  /// 表示側が安定した結果を選べるよう、Search は 4 件の候補を取得します。
  static const int fetchLimit = 4;

  /// 既存の Search 表示は最大 2 件の候補を表示します。
  static const int displayLimit = 2;
}
