import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_command.dart';

class MyWordItemViewModel {
  final MyWordUiState word;
  final MyWordCommand _command;

  MyWordItemViewModel(this.word, this._command);

  String get wordId => word.wordId;
  String get headword => word.word;
  String get contents => word.contents;

  Future<void> deleteWord() => _command.deleteWord();

  void updateWord({
    required String headword,
    required String description,
  }) =>
      _command.updateWord(headword: headword, description: description);
}
