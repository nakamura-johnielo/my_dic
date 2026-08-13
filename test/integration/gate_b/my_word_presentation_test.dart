import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/my_word/internal/presentation/provider/my_word_presentation_providers.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/my_word/port/my_word.dart';

void main() {
  test('a new session epoch gets a re-keyed VM and fresh zero page', () async {
    final ports = _FakePorts();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const first = SessionScopeKey(accountScope: 'guest', epoch: 1);
    const second = SessionScopeKey(accountScope: 'guest', epoch: 2);
    final a = container.read(
        myWordFragmentViewModelProvider((scope: first, ports: ports.value))
            .notifier);
    final b = container.read(
        myWordFragmentViewModelProvider((scope: second, ports: ports.value))
            .notifier);
    expect(identical(a, b), isFalse);
    await a.loadPage(size: 30, page: 0);
    await b.loadPage(size: 30, page: 0);
    expect(ports.accounts, ['guest', 'guest']);
    expect(ports.pages, [0, 0]);
  });
}

class _FakePorts
    implements
        MyWordQueryPort,
        MyWordCommandPort,
        MyWordStatusCommandPort,
        MyWordGuestMigrationPort {
  final pages = <int>[];
  final accounts = <String>[];
  late final value = MyWordPorts(
      reader: this, commands: this, statusCommands: this, guestMigration: this);
  @override
  Future<Result<List<String>>> loadIds(LoadMyWordsQuery query) async {
    pages.add(query.page);
    accounts.add(query.accountScope);
    return const Result.success([]);
  }

  @override
  Stream<MyWordItem?> watchItem(WatchMyWordItemQuery query) =>
      const Stream.empty();
  @override
  Future<Result<String>> register(RegisterMyWordCommand command) async =>
      const Result.success('id');
  @override
  Future<Result<void>> update(UpdateMyWordCommand command) async =>
      const Result.success(null);
  @override
  Future<Result<void>> delete(DeleteMyWordCommand command) async =>
      const Result.success(null);
  @override
  Future<Result<void>> updateStatus(UpdateMyWordStatusCommand command) async =>
      const Result.success(null);
  @override
  Future<MyWordGuestRowCounts> countGuestRows() async =>
      const MyWordGuestRowCounts(words: 0, statuses: 0);
  @override
  Future<void> migrateGuestRows(
      {required String accountId,
      required String migrationId,
      required DateTime Function() clock}) async {}
}
