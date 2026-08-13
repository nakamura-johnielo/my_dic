import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/my_word/internal/presentation/view/my_word_fragment.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/my_word/port/my_word.dart';

void main() {
  const scope = SessionScopeKey(accountScope: 'guest', epoch: 1);

  testWidgets('controlled page owns automatic zero page load', (tester) async {
    final ports = _FakePorts();
    await tester.pumpWidget(ProviderScope(
      child:
          MaterialApp(home: MyWordFragment(scope: scope, ports: ports.value)),
    ));
    await tester.pump();
    expect(ports.pages, [0]);
    expect(find.text('No saved words yet.'), findsOneWidget);
  });
}

class _FakePorts
    implements
        MyWordQueryPort,
        MyWordCommandPort,
        MyWordStatusCommandPort,
        MyWordGuestMigrationPort {
  final pages = <int>[];
  late final value = MyWordPorts(
      reader: this, commands: this, statusCommands: this, guestMigration: this);
  @override
  Future<Result<List<String>>> loadIds(LoadMyWordsQuery query) async {
    pages.add(query.page);
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
