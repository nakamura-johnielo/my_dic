import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

void main() {
  const word = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 7,
  );

  group('WordStatus', () {
    test('retains the complete Catalog word identity', () {
      final status = _status(word: word);

      expect(status.word, word);
      expect(status.word.catalogId, CatalogId.espJpnMain);
      expect(status.word.wordId, 7);
    });

    test('retains a UTC updatedAt timestamp', () {
      final utcTime = DateTime.utc(2026, 8, 9, 10, 30);
      final status = _status(updatedAt: utcTime);

      expect(status.updatedAt, utcTime);
      expect(status.updatedAt.isUtc, isTrue);
    });

    test('copyWith preserves unspecified fields and a new UTC timestamp', () {
      final original = _status(
        isLearned: false,
        isBookmarked: true,
        hasNote: true,
      );
      final replacementWord = const CatalogWordRef(
        catalogId: CatalogId.jpnEspMain,
        wordId: 7,
      );
      final utcTime = DateTime.utc(2026, 8, 10, 10, 30);

      final copied = original.copyWith(
        word: replacementWord,
        isLearned: true,
        updatedAt: utcTime,
      );

      expect(copied.word, replacementWord);
      expect(copied.isLearned, isTrue);
      expect(copied.isBookmarked, isTrue);
      expect(copied.hasNote, isTrue);
      expect(copied.updatedAt, utcTime);
      expect(copied.updatedAt.isUtc, isTrue);
    });
  });
}

WordStatus _status({
  CatalogWordRef word = const CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 7,
  ),
  bool isLearned = true,
  bool isBookmarked = false,
  bool hasNote = false,
  DateTime? updatedAt,
}) {
  return WordStatus(
    word: word,
    isLearned: isLearned,
    isBookmarked: isBookmarked,
    hasNote: hasNote,
    updatedAt: updatedAt ?? DateTime.utc(2026, 8, 9),
  );
}
