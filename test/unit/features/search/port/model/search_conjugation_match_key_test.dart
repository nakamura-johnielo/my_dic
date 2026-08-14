import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/search/port/search.dart';

void main() {
  test('match position is expressed only in Search-owned typed vocabulary', () {
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
