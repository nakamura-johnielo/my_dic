import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_page/application/query/i_load_word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_query_result.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_view_data.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';
import 'package:my_dic/features/word_page/presentation/view_model/word_page_view_model.dart';

void main() {
  const espKey = WordPageLoadKey(
    wordId: 7,
    wordType: WordType.espJpn,
    hasConj: true,
  );

  test('loads one aggregate query exactly once', () async {
    final loader = _Loader(Result.success(_espResult()));
    final model = WordPageViewModel(loader);

    await Future.wait([model.initialize(espKey), model.initialize(espKey)]);

    expect(loader.calls, 1);
    expect(model.state.detail.dataOrNull, isA<EspJpnWordDetailViewData>());
    model.dispose();
  });

  test('maps an empty projection to QueryEmpty', () async {
    final model = WordPageViewModel(_Loader(Result.success(
      WordDetailQueryResult(
        viewData: JpnEspWordDetailViewData(dictionaries: const []),
      ),
    )));

    await model.initialize(const WordPageLoadKey(
      wordId: 3,
      wordType: WordType.jpnEsp,
      hasConj: false,
    ));

    expect(model.state.detail, isA<QueryEmpty<WordDetailViewData>>());
    model.dispose();
  });

  test('maps primary query failure to QueryFailure', () async {
    final model = WordPageViewModel(
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
    final model = WordPageViewModel(_Loader(Result.success(
      WordDetailQueryResult(viewData: _espData, issue: issue),
    )));

    await model.initialize(espKey);

    expect(model.state.detail.dataOrNull, same(_espData));
    expect(model.state.detail.warnings.single.source, 'conjugation');
    model.dispose();
  });

  test('keeps loading state until the query resolves', () async {
    final loader = _DeferredLoader();
    final model = WordPageViewModel(loader);
    final loading = model.initialize(espKey);

    expect(model.state.detail, isA<QueryLoading<WordDetailViewData>>());
    loader.complete(Result.success(_espResult()));
    await loading;

    expect(model.state.detail.dataOrNull, isA<EspJpnWordDetailViewData>());
    model.dispose();
  });
}

const _espDictionary = EspJpnDictionary(dictionaryId: 1, word: 'hablar');
final _espData = EspJpnWordDetailViewData(dictionaries: [_espDictionary]);

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
