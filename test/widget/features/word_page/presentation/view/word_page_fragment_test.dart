import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/presentation/dictionary_status_view_models.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/application/update_status_usecase.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart';
import 'package:my_dic/features/word_page/application/query/i_load_word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_query_result.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_view_data.dart';
import 'package:my_dic/features/word_page/di/view_model_di.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';
import 'package:my_dic/features/word_page/presentation/view/word_page_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view_model/word_page_view_model.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';

void main() {
  const key = WordPageLoadKey(
    wordId: 1,
    wordType: WordType.espJpn,
    hasConj: true,
  );

  testWidgets('updates multi-tab content when the word detail query completes',
      (tester) async {
    final loader = _DeferredLoader();
    final viewModel = WordPageViewModel(loader);
    final loading = viewModel.initialize(key);

    final statusViewModel = EspJpnWordStatusViewModel(
      WordStatusState(status: QueryState.empty()),
      EspJpnWordStatusCommand(1, _NoopUpdateStatusUseCase()),
    );
    final container = ProviderContainer(overrides: [
      wordPageViewModelProvider(key).overrideWith((ref) => viewModel),
      espJpnWordStatusViewModelProvider(1)
          .overrideWith((ref) => statusViewModel),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: WordPageFragment(
            route: WordDetailRoute(
              wordId: 1,
              wordType: WordType.espJpn,
              hasConj: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    loader.complete(Result.success(WordDetailQueryResult(
      viewData: EspJpnWordDetailViewData(dictionaries: const [
        EspJpnDictionary(
          dictionaryId: 1,
          word: 'hablar',
          headword: 'hablar',
          content: '<p>hablar</p>',
        ),
      ]),
    )));
    await loading;
    await tester.pump();

    expect(find.text('hablar'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

class _DeferredLoader implements ILoadWordDetailQuery {
  final _result = Completer<Result<WordDetailQueryResult>>();

  void complete(Result<WordDetailQueryResult> result) =>
      _result.complete(result);

  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) =>
      _result.future;
}

class _NoopUpdateStatusUseCase implements IUpdateStatusUseCase {
  @override
  Future<Result<void>> execute(UpdateStatusInputData input) async =>
      const Result.success(null);
}
