/// Quiz の制御されたプレゼンテーションエントリ用の内部ブリッジ。
///
/// Quiz はゲームと検索の実装を別々のサブ機能に保持しつつ、公開エントリではこの正規の
/// プレゼンテーションビュー境界のみをインポートする。
library;

export '../game/view/quiz_game_fragment.dart' show QuizGameFragment;
export '../search/view/quiz_search_fragment.dart' show QuizSearchFragment;
