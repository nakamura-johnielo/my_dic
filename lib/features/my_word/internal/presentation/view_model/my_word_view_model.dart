import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';

class MyWordFragmentViewModel extends StateNotifier<MyWordFragmentState> {
  MyWordFragmentViewModel(
      this._loadMyWordInteractor, this._registerMyWordInteractor, this._scope)
      : super(const MyWordFragmentState());

  final ILoadMyWordUseCase _loadMyWordInteractor;
  final IRegisterMyWordUseCase _registerMyWordInteractor;
  final SessionScopeKey _scope;
  int _generation = 0;
  final _attempts = <MyWordPageIdentity, int>{};
  final _inFlight = <MyWordPageIdentity, Future<bool>>{};
  final _activeTokens = <MyWordPageIdentity, MyWordRequestToken>{};
  MyWordPageIdentity? _failedPage;

  void reset() {
    _generation++;
    _attempts.clear();
    _inFlight.clear();
    _activeTokens.clear();
    _failedPage = null;
    state = const MyWordFragmentState();
  }

  /// Requests a zero-based page. Identity and retries are owned here, not by
  /// the shared scroll controller.
  Future<bool> loadPage({required int size, required int page}) {
    final identity = MyWordPageIdentity(scope: _scope, page: page, size: size);
    return _inFlight.putIfAbsent(identity, () => _load(identity));
  }

  // Compatibility for existing presentation callers while migrating to the
  // explicit zero-based page API.
  Future<void> loadNext(int size, int currentPage) async {
    await loadPage(size: size, page: currentPage + 1);
  }

  Future<bool> retryFailed() {
    final failed = _failedPage;
    if (failed == null || failed.scope != _scope) return Future.value(false);
    return loadPage(size: failed.size, page: failed.page);
  }

  Future<void> retry(int size) async => retryFailed();

  Future<bool> _load(MyWordPageIdentity identity) async {
    final token = MyWordRequestToken(
      generation: _generation,
      pageIdentity: identity,
      attempt: (_attempts[identity] ?? 0) + 1,
    );
    _attempts[identity] = token.attempt;
    _activeTokens[identity] = token;
    final previous = state.words.dataOrNull;
    state = state.copyWith(words: QueryState.loading(previousData: previous));
    try {
      final result = await _loadMyWordInteractor.executeIds(
        LoadMyWordInputData(identity.size, identity.page, _scope.accountScope),
      );
      if (!_isCurrent(token)) return false;
      return result.when(success: (words) {
        // Capture current state after await so a response cannot overwrite a
        // page published while this request was suspended.
        final current = state.words.dataOrNull;
        final value = identity.page == 0
            ? MyWordListResults(words).append(const [])
            : (current ?? const MyWordListResults([])).append(words);
        state = state.copyWith(
          words:
              value.ids.isEmpty ? QueryState.empty() : QueryState.data(value),
          currentPage: identity.page,
          hasNext: words.length == identity.size,
        );
        _failedPage = null;
        return words.length == identity.size;
      }, failure: (error) {
        AppLogger.print('Failed to load words: ${error.message}');
        state = state.copyWith(
          words:
              QueryState.failure(error, previousData: state.words.dataOrNull),
        );
        _failedPage = identity;
        return false;
      });
    } finally {
      if (_activeTokens[identity] == token) _activeTokens.remove(identity);
      _inFlight.remove(identity);
    }
  }

  bool _isCurrent(MyWordRequestToken token) =>
      mounted &&
      token.generation == _generation &&
      _activeTokens[token.pageIdentity] == token;

  Future<Result<String>> registerWord({
    required String headword,
    required String description,
    void Function()? onComplete,
    void Function()? onError,
    void Function()? onInvalid,
  }) async {
    final result = await _registerMyWordInteractor.execute(
      RegisterMyWordInputData(headword, description, _scope.accountScope),
    );
    result.when(
      success: (_) => onComplete?.call(),
      failure: (error) {
        AppLogger.print('Failed to register word: ${error.message}');
        onError?.call();
        onInvalid?.call();
      },
    );
    return result;
  }
}

final class MyWordPageIdentity {
  const MyWordPageIdentity(
      {required this.scope, required this.page, required this.size});
  final SessionScopeKey scope;
  final int page;
  final int size;
  @override
  bool operator ==(Object other) =>
      other is MyWordPageIdentity &&
      other.scope == scope &&
      other.page == page &&
      other.size == size;
  @override
  int get hashCode => Object.hash(scope, page, size);
}

final class MyWordRequestToken {
  const MyWordRequestToken(
      {required this.generation,
      required this.pageIdentity,
      required this.attempt});
  final int generation;
  final MyWordPageIdentity pageIdentity;
  final int attempt;
  @override
  bool operator ==(Object other) =>
      other is MyWordRequestToken &&
      other.generation == generation &&
      other.pageIdentity == pageIdentity &&
      other.attempt == attempt;
  @override
  int get hashCode => Object.hash(generation, pageIdentity, attempt);
}
