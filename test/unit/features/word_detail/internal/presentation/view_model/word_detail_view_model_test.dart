import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view_model/word_detail_view_model.dart';
import 'package:my_dic/features/word_detail/port/query.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);
  const key = WordDetailLoadKey(word);

  test('late completion after dispose is fenced by generation and mounted',
      () async {
    final loader = _DeferredLoader();
    final viewModel = WordDetailViewModel(loader);

    final pending = viewModel.initialize(key);
    viewModel.dispose();
    loader.complete(Result.success(WordDetailQueryResult(
      viewData: EspJpnWordDetailViewData(
        word: word,
        entries: [EspJpnEntry(dictionaryId: 1, word: 'hablar')],
      ),
    )));
    await pending;

    expect(loader.calls, 1);
  });
}

final class _DeferredLoader implements ILoadWordDetailQuery {
  final _result = Completer<Result<WordDetailQueryResult>>();
  var calls = 0;

  void complete(Result<WordDetailQueryResult> result) =>
      _result.complete(result);

  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) {
    calls++;
    return _result.future;
  }
}
