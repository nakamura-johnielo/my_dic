abstract class IQuizLocalDataSource {
  Future<Map<String, String>> getConjEnglishGuide();

  Future<Map<String, Map<String, String>>> getConjOfBe();
}
