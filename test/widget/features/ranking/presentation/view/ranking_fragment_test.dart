import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/application/query/ranking_page.dart';
import 'package:my_dic/features/ranking/di/usecase_di.dart';
import 'package:my_dic/features/ranking/di/view_model_di.dart';
import 'package:my_dic/features/ranking/presentation/view/ranking_fragment.dart';

import '../../../../../helpers/fake_ranking_usecases.dart';

void main() {
  testWidgets('loads the initial page and reloads it after a filter change',
      (tester) async {
    final loadUseCase = FakeLoadRankingsUseCase(
      result: Result.success(
        RankingPage(items: const [], hasNext: false),
      ),
    );
    final container = ProviderContainer(overrides: [
      loadRankingsUseCaseProvider.overrideWithValue(loadUseCase),
      updateRankingFilterUseCaseProvider
          .overrideWithValue(FakeUpdateRankingFilterUseCase()),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: RankingFragment()),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadUseCase.inputs, hasLength(1));
    expect(find.text('No rankings found.'), findsOneWidget);

    container
        .read(rankingViewModelProvider.notifier)
        .addFilter(PartOfSpeech.noun);
    await tester.pumpAndSettle();

    expect(loadUseCase.inputs, hasLength(2));
    expect(loadUseCase.inputs.last.partOfSpeechFilters[PartOfSpeech.noun], 1);
  });
}
