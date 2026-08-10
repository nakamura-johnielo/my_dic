import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/my_word/port/guest_migration.dart';

final class MyWordGuestMigrationAdapter implements MyWordGuestMigrationPort {
  const MyWordGuestMigrationAdapter(this._myWord, this._myWordStatus);

  final IMyWordLocalDataSource _myWord;
  final IMyWordStatusLocalDataSource _myWordStatus;

  @override
  Future<int> countGuestMyWords() async =>
      (await _myWord.getAllByAccountId(guestAccountScope)).length;

  @override
  Future<int> countGuestMyWordStatuses() async =>
      (await _myWordStatus.getAllByAccountId(guestAccountScope)).length;
}
