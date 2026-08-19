const catalogLikeEscapeCharacter = '!';

/// ユーザー入力をリテラルとして扱い、前方一致検索に必要な末尾ワイルドカード 1 つだけを
/// 追加する SQLite LIKE パターンを生成する。
String catalogPrefixLikePattern(String input) =>
    '${input.replaceAll('!', '!!').replaceAll('%', '!%').replaceAll('_', '!_')}%';
