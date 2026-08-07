import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/application/fetch_english_conj/fetch_english_conj_interactor.dart';
import 'package:my_dic/features/quiz/application/fetch_english_conj_sub/fetch_english_conj_sub_interactor.dart';
import 'package:my_dic/features/quiz/domain/repository/i_es_en_conjugacion_repository.dart';
import 'package:my_dic/features/quiz/domain/repository/i_english_conj_sub_repository.dart';

class _EnglishConjugationRepository implements IEsEnConjugacionRepository {
  int? receivedWordId;

  @override
  Future<Result<Map<String, String>>> getEnglishConjById(int id) async {
    receivedWordId = id;
    return Result.success({'present': 'speak'});
  }
}

class _EnglishConjugationTemplateRepository
    implements IEnglishConjSubRepository {
  @override
  Future<Result<Map<String, String>>> getConjEnglishGuide() async =>
      Result.success({'guide': 'It is important that @ #'});

  @override
  Future<Result<Map<String, Map<String, String>>>> getConjOfBe() async =>
      Result.success({
        'present': {'he': 'is'},
      });
}

void main() {
  test('fetches an English conjugation through the domain repository port',
      () async {
    final repository = _EnglishConjugationRepository();
    final useCase = FetchEnglishConjInteractor(repository);

    final result = await useCase.execute(42);

    expect(repository.receivedWordId, 42);
    expect(result.dataOrNull, {'present': 'speak'});
  });

  test('fetches English quiz templates through the domain repository port',
      () async {
    final useCase = FetchEnglishConjSubInteractor(
      repository: _EnglishConjugationTemplateRepository(),
    );

    final guide = await useCase.getConjEnglishGuide();
    final beConjugation = await useCase.getConjOfBe();

    expect(guide.dataOrNull, {'guide': 'It is important that @ #'});
    expect(beConjugation.dataOrNull, {
      'present': {'he': 'is'},
    });
  });
}
