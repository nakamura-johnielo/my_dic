import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/quiz/application/fetch_english_conj/i_fetch_english_conj_usecase.dart';
import 'package:my_dic/features/quiz/consts/card_state.dart';
import 'package:my_dic/features/quiz/di/usecase_di.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_game_viewmodel.dart';

class _FakeConjugationReader implements ConjugationReader {
  CatalogWordRef? requestedWord;

  @override
  Future<Result<CatalogConjugation?>> getConjugation(
    CatalogWordRef word,
  ) async {
    requestedWord = word;
    return const Result.success(null);
  }

  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) async =>
      const Result.success(false);
}

class _FakeFetchEnglishConjUseCase implements IFetchEnglishConjUseCase {
  @override
  Future<Result<Map<String, String>>> execute(int wordId) async =>
      const Result.success({});
}

void main() {
  QuizGameViewModel createViewModel() => QuizGameViewModel(
        _FakeConjugationReader(),
        _FakeFetchEnglishConjUseCase(),
      );

  test('initialize selects the first question and resets the card to question',
      () {
    final viewModel = createViewModel();

    viewModel.toggleQuizCardStatus();
    viewModel.initialize();

    expect(viewModel.state.allLength, greaterThan(0));
    expect(viewModel.state.currentIndex, 0);
    expect(viewModel.state.hasCurrentQuestion, isTrue);
    expect(viewModel.state.quizCardState, QuizCardState.question);
  });

  test('DI converts the raw Quiz route ID to the Esp-Jpn Catalog identity',
      () async {
    final reader = _FakeConjugationReader();
    final container = ProviderContainer(overrides: [
      conjugationReaderProvider.overrideWithValue(reader),
      fetchEnglishConjUseCaseProvider.overrideWithValue(
        _FakeFetchEnglishConjUseCase(),
      ),
    ]);
    addTearDown(container.dispose);

    await container.read(quizConjugacionsProvider(41).future);

    expect(
      reader.requestedWord,
      const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 41),
    );
  });
}
