/// Extracts all dictionary meaning elements as plain text without truncating.
String extractMeaningText(String html) {
  final elements = RegExp(
    r'<p data-orgtag="meaning"[^>]*>(.*?)</p>',
    dotAll: true,
  ).allMatches(html);
  final meanings = elements
      .map((match) => _stripTags(match.group(1)!))
      .where((meaning) => meaning.isNotEmpty)
      .toList(growable: false);
  return meanings.join('  ');
}

int starCountFromHeadword(String headword) {
  final match = RegExp(r'<sup>\((\*+)\)</sup>').firstMatch(headword);
  return match?.group(1)?.length ?? 0;
}

/// Selects the row associated with the lowest ranking identifier.
T? selectLowestRanking<T>(Iterable<T> values, int Function(T) rankingId) {
  T? selected;
  for (final value in values) {
    if (selected == null || rankingId(value) < rankingId(selected)) {
      selected = value;
    }
  }
  return selected;
}

String _stripTags(String value) =>
    value.replaceAll(RegExp(r'<[^>]+>'), '').trim();
