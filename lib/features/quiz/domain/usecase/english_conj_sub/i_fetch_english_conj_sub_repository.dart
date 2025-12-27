abstract class IEnglishConjSubRepository {
  //TODO result
  Future<Map<String, String>> getConjEnglishGuide();
  Future<Map<String, Map<String, String>>> getConjOfBe();
}