import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/catalog_html_text.dart';

void main() {
  group('Catalog HTML text', () {
    test('extracts every meaning element without truncating', () {
      final longMeaning = 'a' * 80;
      final result = extractCatalogMeaningText(
        '<p data-orgtag="meaning">first <b>meaning</b></p>'
        '<p data-orgtag="meaning">$longMeaning</p>',
      );

      expect(result, 'first meaning  $longMeaning');
      expect(result.length, greaterThan(30));
    });
  });
}
