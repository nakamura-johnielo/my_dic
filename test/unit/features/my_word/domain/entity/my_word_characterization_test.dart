import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

void main() {
  test('MyWord copyWith preserves and replaces its write fields', () {
    final word = MyWord(
      wordId: 'word-1',
      word: 'hola',
      contents: 'greeting',
      editAt: DateTime.utc(2026, 8, 9),
    );

    final updated = word.copyWith(
      word: 'adios',
      contents: 'salutation',
      editAt: DateTime.utc(2026, 8, 10),
    );

    expect(updated.wordId, 'word-1');
    expect(updated.word, 'adios');
    expect(updated.contents, 'salutation');
    expect(updated.editAt, DateTime.utc(2026, 8, 10));
  });
}
