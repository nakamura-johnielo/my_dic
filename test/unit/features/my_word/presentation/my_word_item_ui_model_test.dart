import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/my_word/internal/application/query/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';

void main() {
  test('maps all card status from the read projection', () {
    final item = MyWordItemUiModel.fromProjection(
      MyWordItemProjection(
        word: MyWord(wordId: 'word-1', word: 'casa', contents: 'home'),
        status: MyWordStatus(
          wordId: 'word-1',
          isLearned: true,
          isBookmarked: true,
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
