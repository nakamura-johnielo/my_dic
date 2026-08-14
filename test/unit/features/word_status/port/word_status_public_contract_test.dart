import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

void main() {
  const first = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 1,
  );
  const second = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 2,
  );

  test('typed account scope rejects an empty account identity', () {
    expect(() => WordStatusScope.account('  '), throwsArgumentError);
    expect(
      WordStatusScope.account('account-a'),
      equals(WordStatusScope.account('account-a')),
    );
    expect(const WordStatusScope.guest(), isA<GuestWordStatusScope>());
  });

  test('physical row absence is represented without an epoch sentinel', () {
    const status = WordStatus.initial(first);
    expect(status.isLearned, isFalse);
    expect(status.isBookmarked, isFalse);
    expect(status.hasNote, isFalse);
    expect(status.updatedAt, isNull);
  });

  test('batch query is immutable and deduplicates in first-input order', () {
    final source = <CatalogWordRef>[first, second, first];
    final query = ReadWordStatusBatchQuery(
      scope: const WordStatusScope.guest(),
      words: source,
    );
    source.clear();

    expect(query.words, [first, second]);
    expect(() => query.words.add(first), throwsUnsupportedError);
  });

  test('new update command owns scope and exposes no timestamp', () {
    const command = UpdateWordStatusCommand(
      scope: WordStatusScope.guest(),
      word: first,
      isLearned: FieldUpdate.set(true),
    );
    expect(command.hasChanges, isTrue);
    expect(command.scope, const WordStatusScope.guest());
  });
}
