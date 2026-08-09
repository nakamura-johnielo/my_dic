import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/search/application/query/search_conjugation_match_key.dart';

void main() {
  test('every Search match key round-trips its stable wire value', () {
    for (final key in SearchConjugationMatchKey.values) {
      expect(SearchConjugationMatchKey.tryFromWireValue(key.wireValue), key);
    }
    expect(
        SearchConjugationMatchKey.tryFromWireValue('unknown_column'), isNull);
  });

  test('match position is expressed only in Search-owned vocabulary', () {
    expect(
      SearchConjugationMatchKey.indicativePresentNosotros.moodTense,
      SearchMoodTense.indicativePresent,
    );
    expect(
      SearchConjugationMatchKey.indicativePresentNosotros.subject,
      SearchSubject.nosotros,
    );
    expect(
      SearchConjugationMatchKey.presentParticiple.subject,
      SearchSubject.yo,
    );
  });
}
