/// Extracts all dictionary meaning elements as plain text without truncating.
String extractCatalogMeaningText(String html) {
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

String _stripTags(String value) =>
    value.replaceAll(RegExp(r'<[^>]+>'), '').trim();
