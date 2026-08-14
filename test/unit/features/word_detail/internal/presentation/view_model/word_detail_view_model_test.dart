import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view_model/word_detail_view_model.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);
  const key = WordDetailLoadKey(word);

  test('late completion after dispose is fenced', () async {
    final reader = _DeferredReader();
    final viewModel = WordDetailViewModel(reader);

    final pending = viewModel.initialize(key);
    viewModel.dispose();
    reader.complete(Result.success(WordDetailResult(data: _data(word))));
    await pending;

    expect(reader.calls, 1);
  });

  test('initialize performs one read per provider instance', () async {
    final reader = _DeferredReader();
    final viewModel = WordDetailViewModel(reader);

    final first = viewModel.initialize(key);
    final second = viewModel.initialize(key);
    reader.complete(Result.success(WordDetailResult(data: _data(word))));
    await Future.wait([first, second]);

    expect(reader.calls, 1);
    expect(viewModel.state.detail.dataOrNull, isA<EspJpnWordDetailData>());
  });
}

EspJpnWordDetailData _data(CatalogWordRef word) => EspJpnWordDetailData(
      word: word,
      entries: [
        WordDetailEspJpnEntry(
          dictionaryId: 1,
          word: 'hablar',
          headword: WordDetailContent.text('hablar'),
          content: WordDetailContent.text('to speak'),
        ),
      ],
    );

final class _DeferredReader implements WordDetailReaderPort {
  final _result = Completer<Result<WordDetailResult>>();
  var calls = 0;

  void complete(Result<WordDetailResult> result) => _result.complete(result);

  @override
  Future<Result<WordDetailResult>> read(WordDetailQuery query) {
    calls++;
    return _result.future;
  }
}
