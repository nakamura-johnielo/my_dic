class JpnEspWord {
  final int id;
  final String word;

  const JpnEspWord({
    required this.id,
    required this.word,
  });

  JpnEspWord copyWith({
    int? id,
    String? word,
  }) {
    return JpnEspWord(
      id: id ?? this.id,
      word: word ?? this.word,
    );
  }
}
