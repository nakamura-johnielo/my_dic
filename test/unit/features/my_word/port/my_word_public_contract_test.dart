import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/my_word/port/my_word.dart';

void main() {
  group('MyWord business facade', () {
    test('exposes immutable public snapshots with value equality', () {
      final updatedAt = DateTime.utc(2026, 8, 11);
      final word = MyWord(
        wordId: 'word-1',
        headword: 'headword',
        description: 'description',
        updatedAt: updatedAt,
      );
      final status = MyWordStatus(
        wordId: 'word-1',
        isLearned: false,
        isBookmarked: true,
        hasNote: false,
        updatedAt: updatedAt,
      );

      expect(word.copyWith(), word);
      expect(status.copyWith(isLearned: true).isLearned, isTrue);
      expect(MyWordItem(word: word, status: status),
          MyWordItem(word: word, status: status));
    });

    test('keeps mutations and queries framework-free data contracts', () {
      const statusUpdate = UpdateMyWordStatusCommand(
        myWordId: 'word-1',
        isLearned: FieldUpdate<bool>.set(true),
        accountScope: 'account-1',
      );
      const page = LoadMyWordsQuery(
        size: 20,
        page: 0,
        accountScope: 'account-1',
      );
      const counts = MyWordGuestRowCounts(words: 2, statuses: 3);

      expect(statusUpdate.hasChanges, isTrue);
      expect(page.size, 20);
      expect(counts.statuses, 3);
    });
  });
}
