class SearchWordInputData {
  final String word;
  int size;
  int page;
  bool forQuiz;
  SearchWordInputData(this.word, this.size, this.page, this.forQuiz);
}

class SearchJpnEspWordInputData {
  String word;
  int size;
  int page;
  SearchJpnEspWordInputData(this.word, this.size, this.page);
}

class SearchConjugacionInputData {
  String word;
  int size;
  int page;
  SearchConjugacionInputData(this.word, this.size, this.page);
}
