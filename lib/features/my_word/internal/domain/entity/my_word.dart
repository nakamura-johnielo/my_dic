import 'package:meta/meta.dart';

@immutable
class MyWord {
  final String wordId;
  final String word;
  final String contents;
  final DateTime editAt;

  MyWord({
    required this.wordId,
    required this.word,
    required this.contents,
    DateTime? editAt,
  }) : editAt = (editAt ?? DateTime.now()).toUtc();

  MyWord copyWith({
    String? wordId,
    String? word,
    String? contents,
    DateTime? editAt,
  }) {
    return MyWord(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      contents: contents ?? this.contents,
      editAt: editAt ?? this.editAt,
    );
  }
}
