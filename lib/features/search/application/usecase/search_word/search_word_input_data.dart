class SearchWordInputData {
  final String word;
  final int size;
  final int page;
  final bool forQuiz;
  const SearchWordInputData(this.word, this.size, this.page, this.forQuiz);
}

class SearchJpnEspWordInputData {
  final String word;
  final int size;
  final int page;
  const SearchJpnEspWordInputData(this.word, this.size, this.page);
}

class SearchConjugacionInputData {
  final String word;
  final int size;
  final int page;
  const SearchConjugacionInputData(this.word, this.size, this.page);
}
