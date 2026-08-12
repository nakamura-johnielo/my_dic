import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_view_model.dart';
import 'package:my_dic/features/my_word/port/my_word.dart';

void main() {
  late _DeferredLoadWords loader;
  late MyWordFragmentViewModel viewModel;

  setUp(() {
    loader = _DeferredLoadWords();
    viewModel = MyWordFragmentViewModel(
      loader,
      _RegisterWords(),
      const SessionScopeKey(accountScope: 'guest', epoch: 1),
    );
  });

  tearDown(() {
    if (viewModel.mounted) viewModel.dispose();
  });

  test('page zero replaces and page one appends with stable wordId dedupe',
      () async {
    final first = viewModel.loadPage(size: 2, page: 0);
    loader.complete(0, const Result.success(['a', 'b']));
    await first;
    final second = viewModel.loadPage(size: 2, page: 1);
    loader.complete(1, const Result.success(['b', 'c']));
    await second;

    expect(viewModel.state.myWordIds, ['a', 'b', 'c']);
    expect(viewModel.state.currentPage, 1);
  });

  test('same page is single-flight and retry targets the failed identity',
      () async {
    final first = viewModel.loadPage(size: 2, page: 1);
    final duplicate = viewModel.loadPage(size: 2, page: 1);
    expect(loader.inputs, hasLength(1));
    expect(identical(first, duplicate), isTrue);
    loader.complete(1, Result.failure(DatabaseError(message: 'nope')));
    await first;

    final retry = viewModel.retryFailed();
    expect(loader.inputs, hasLength(2));
    expect(loader.inputs.last.page, 1);
    loader.complete(1, const Result.success(['retry']));
    await retry;
    expect(viewModel.state.myWordIds, ['retry']);
  });

  test('reset prevents an old response from publishing', () async {
    final old = viewModel.loadPage(size: 2, page: 0);
    viewModel.reset();
    loader.complete(0, const Result.success(['old']));
    await old;
    expect(viewModel.state.words, isA<QueryInitial<MyWordListResults>>());
  });

  test('dispose prevents an in-flight response from publishing', () async {
    final request = viewModel.loadPage(size: 2, page: 0);
    viewModel.dispose();
    loader.complete(0, const Result.success(['late']));
    await expectLater(request, completes);
  });
}

class _DeferredLoadWords implements MyWordReaderPort {
  final inputs = <LoadMyWordsQuery>[];
  final _requests = <int, List<Completer<Result<List<String>>>>>{};

  @override
  Future<Result<List<String>>> loadIds(LoadMyWordsQuery input) {
    inputs.add(input);
    final completer = Completer<Result<List<String>>>();
    _requests.putIfAbsent(input.page, () => []).add(completer);
    return completer.future;
  }

  void complete(int page, Result<List<String>> value) =>
      _requests[page]!.removeAt(0).complete(value);

  @override
  Stream<MyWordItem?> watchItem(WatchMyWordItemQuery query) =>
      throw UnimplementedError();
}

class _RegisterWords implements MyWordCommandPort {
  @override
  Future<Result<String>> register(RegisterMyWordCommand input) async =>
      const Result.success('id');

  @override
  Future<Result<void>> update(UpdateMyWordCommand command) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> delete(DeleteMyWordCommand command) =>
      throw UnimplementedError();
}
