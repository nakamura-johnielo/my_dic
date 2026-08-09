import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/application/model/update_word_status_command.dart';

void main() {
  const word = CatalogWordRef(
    catalogId: CatalogId.jpnEspMain,
    wordId: 11,
  );

  group('UpdateWordStatusCommand', () {
    test('defaults every field update to unchanged', () {
      const command = UpdateWordStatusCommand(word: word);

      expect(command.word, word);
      expect(command.isLearned, isA<Unchanged<bool>>());
      expect(command.isBookmarked, isA<Unchanged<bool>>());
      expect(command.hasNote, isA<Unchanged<bool>>());
      expect(command.hasChanges, isFalse);
    });

    test('distinguishes setting false from leaving a field unchanged', () {
      const command = UpdateWordStatusCommand(
        word: word,
        isBookmarked: FieldUpdate.set(false),
      );

      expect(command.isBookmarked, isA<SetValue<bool>>());
      expect((command.isBookmarked as SetValue<bool>).value, isFalse);
      expect(command.hasChanges, isTrue);
    });
  });
}
