const catalogLikeEscapeCharacter = '!';

/// Produces a SQLite LIKE pattern that treats user input literally and only
/// adds the single trailing wildcard required for prefix search.
String catalogPrefixLikePattern(String input) =>
    '${input.replaceAll('!', '!!').replaceAll('%', '!%').replaceAll('_', '!_')}%';
