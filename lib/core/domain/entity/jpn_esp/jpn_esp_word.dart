import 'package:flutter/foundation.dart';

@immutable
class JpnEspWord {
  final int id;
  final String word;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  const JpnEspWord({
    required this.id,
    required this.word,
    this.isLearned = false,
    this.isBookmarked = false,
    this.hasNote = false,
  });

  JpnEspWord copyWith({
    int? id,
    String? word,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
  }) {
    return JpnEspWord(
      id: id ?? this.id,
      word: word ?? this.word,
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
    );
  }
}
