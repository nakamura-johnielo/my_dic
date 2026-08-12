import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/port/my_word.dart';

void main() {
  test('maps all card status from the read projection', () {
    final item = MyWordItemUiModel.fromItem(
      MyWordItem(
        word: MyWord(
            wordId: 'word-1',
            headword: 'casa',
            description: 'home',
            updatedAt: DateTime.utc(2026)),
        status: MyWordStatus(
          wordId: 'word-1',
          isLearned: true,
          isBookmarked: true,
          hasNote: false,
          updatedAt: DateTime.utc(2026),
        ),
      ),
    );

    expect(item.wordId, 'word-1');
    expect(item.word, 'casa');
    expect(item.contents, 'home');
    expect(item.isLearned, isTrue);
    expect(item.isBookmarked, isTrue);
  });
}
