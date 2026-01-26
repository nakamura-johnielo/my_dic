import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_command.dart';

class MyWordItemViewModel {
  final MyWordUiState word;
  final MyWordCommand _command;

  MyWordItemViewModel(this.word, this._command);

  String get wordId => word.wordId;
  String get headword => word.word;
  String get contents => word.contents;

  void deleteWord({required void Function() onComplete}) {
    _command.deleteWord(onComplete: onComplete);
  }

  void updateWord({
    required String headword,
    required String description,
    required int index,
    required void Function() onComplete,
  }) {
    _command.updateWord(
      headword: headword,
      description: description,
      index: index,
      onComplete: onComplete,
    );
  }
}
