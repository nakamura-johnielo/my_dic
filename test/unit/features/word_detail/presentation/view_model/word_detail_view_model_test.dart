import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view_model/word_detail_view_model.dart';
import 'package:my_dic/features/word_detail/port/query.dart';

void main() {
  const espKey = WordDetailLoadKey(_espWord);

  test('loads one aggregate query exactly once', () async {
    final loader = _Loader(Result.success(_espResult()));
    final model = WordDetailViewModel(loader);

    await Future.wait([model.initialize(espKey), model.initialize(espKey)]);

    expect(loader.calls, 1);
    expect(model.state.detail.dataOrNull, isA<EspJpnWordDetailViewData>());
    model.dispose();
  });

  test('maps an empty projection to QueryEmpty', () async {
    final model = WordDetailViewModel(_Loader(Result.success(
      WordDetailQueryResult(
        viewData: JpnEspWordDetailViewData(
          word: CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 3),
          entries: const [],
        ),
      ),
    )));

    await model.initialize(const WordDetailLoadKey(
      CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 3),
    ));

    expect(model.state.detail, isA<QueryEmpty<WordDetailViewData>>());
    model.dispose();
  });

  test('maps primary query failure to QueryFailure', () async {
    final model = WordDetailViewModel(
      _Loader(Result.failure(BusinessRuleError(message: 'dictionary failed'))),
    );

    await model.initialize(espKey);

    expect(model.state.detail, isA<QueryFailure<WordDetailViewData>>());
    model.dispose();
  });

  test('keeps successful view data with a conjugation warning', () async {
    final issue = QueryIssue(
      source: 'conjugation',
      error: BusinessRuleError(message: 'conjugation failed'),
    );
    final model = WordDetailViewModel(_Loader(Result.success(
      WordDetailQueryResult(viewData: _espData, issue: issue),
    )));

    await model.initialize(espKey);

    expect(model.state.detail.dataOrNull, same(_espData));
    expect(model.state.detail.warnings.single.source, 'conjugation');
    model.dispose();
  });

  test('keeps loading state until the query resolves', () async {
    final loader = _DeferredLoader();
    final model = WordDetailViewModel(loader);
    final loading = model.initialize(espKey);

    expect(model.state.detail, isA<QueryLoading<WordDetailViewData>>());
    loader.complete(Result.success(_espResult()));
    await loading;

    expect(model.state.detail.dataOrNull, isA<EspJpnWordDetailViewData>());
    model.dispose();
  });
}

const _espWord = CatalogWordRef(
  catalogId: CatalogId.espJpnMain,
  wordId: 7,
);
final _espData = EspJpnWordDetailViewData(
  word: _espWord,
  entries: [EspJpnEntry(dictionaryId: 1, word: 'hablar')],
);

WordDetailQueryResult _espResult() => WordDetailQueryResult(viewData: _espData);

class _Loader implements ILoadWordDetailQuery {
  _Loader(this.result);
  final Result<WordDetailQueryResult> result;
  var calls = 0;

  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) async {
    calls++;
    return result;
  }
}

class _DeferredLoader implements ILoadWordDetailQuery {
  final _result = Completer<Result<WordDetailQueryResult>>();

  void complete(Result<WordDetailQueryResult> result) =>
      _result.complete(result);

  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) =>
      _result.future;
}
