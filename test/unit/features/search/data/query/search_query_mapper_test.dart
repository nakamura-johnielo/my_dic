import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/search/data/query/search_query_mapper.dart';

void main() {
  group('Search query mapper', () {
    test('extracts every meaning element without truncating', () {
      final longMeaning = 'a' * 80;
      final result = extractMeaningText(
        '<p data-orgtag="meaning">first <b>meaning</b></p>'
        '<p data-orgtag="meaning">$longMeaning</p>',
      );

      expect(result, 'first meaning  $longMeaning');
      expect(result.length, greaterThan(30));
    });

    test('counts star markup and treats an unmarked headword as zero', () {
      expect(starCountFromHeadword('casa<sup>(***)</sup>'), 3);
      expect(starCountFromHeadword('casa'), 0);
    });

    test('selects the duplicate ranking row with the lowest identifier', () {
      final selected = selectLowestRanking(
        const [_Rank(9, 300), _Rank(2, 100), _Rank(4, 200)],
        (value) => value.id,
      );

      expect(selected?.rankingNo, 100);
    });
  });
}

class _Rank {
  const _Rank(this.id, this.rankingNo);

  final int id;
  final int rankingNo;
}
