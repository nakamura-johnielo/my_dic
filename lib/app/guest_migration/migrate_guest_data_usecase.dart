import 'package:my_dic/features/my_word/port/my_word.dart';
import 'package:uuid/uuid.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/sync.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

///
///
/// ゲストスコープのローカル行をすべて、ログイン済みアカウントへアトミックに移動します。
/// 単語ステータス（esp_jpn/jpn_esp）エンティティは、共有辞書の wordId をキーとしているため、
/// 同じ単語に対してゲスト行と既存のアカウント行が正当に共存することが可能です。
/// それらのブール値フィールドは OR 演算で統合され（true の方が優先）、
/// 行はアカウントスコープ下に書き込まれた後、ゲスト行は削除されます。
/// MyWord/MyWordStatusエンティティは、作成時に生成されるUUIDをキーとするため、
/// 実際にはゲスト行とアカウント行の間でIDが衝突することは想定されていません。
/// これらの行は単にその場でキーが更新されます。また、事実上あり得ない衝突が発生した場合でも、
/// アカウントの既存の行が保持され、ゲスト行はそのまま残されます（移行されません）。

/// 冪等性：承認された各実行は1つの移行IDを生成し、そのアウトボックスへの変更操作で共有されます。
/// トランザクションが成功した場合、ゲストスコープの行は残らないため、後の実行はノーオペレーションとなります。
/// トランザクションが失敗した場合は、両方の行とキューに格納された変更操作がまとめてロールバックされます。

class MigrateGuestDataUseCase {
  MigrateGuestDataUseCase({
    required DatabaseProvider database,
    required WordStatusGuestMigrationPort wordStatus,
    required MyWordGuestMigrationPort myWord,
    required UserProfileGuestMigrationPort userProfile,
    OutboxWriter? outboxWriter,
    required SessionFence sessionFence,
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _database = database,
        _wordStatus = wordStatus,
        _myWord = myWord,
        _userProfile = userProfile,
        _sessionFence = sessionFence,
        _uuid = uuid ?? const Uuid(),
        _clock = clock ?? DateTime.now;

  final DatabaseProvider _database;
  final WordStatusGuestMigrationPort _wordStatus;
  final MyWordGuestMigrationPort _myWord;
  final UserProfileGuestMigrationPort _userProfile;
  final SessionFence _sessionFence;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<void> execute(String accountId, int sessionEpoch) async {
    _ensureCurrent(accountId, sessionEpoch);
    final migrationId = _uuid.v4();
    await _database.transaction(() async {
      _ensureCurrent(accountId, sessionEpoch);
      await _wordStatus.migrateGuestRows(
        accountId: accountId,
        migrationId: migrationId,
        clock: _clock,
      );
      await _myWord.migrateGuestRows(
        accountId: accountId,
        migrationId: migrationId,
        clock: _clock,
      );
      await _migrateUserProfile(accountId, migrationId);
      // ここでのスローは意図的です。処理中にユーザーがアカウントを切り替えた場合、Driftは
      // 移行済みのすべての行とアウトボックス変更をロールバックします。
      _ensureCurrent(accountId, sessionEpoch);
    });
  }

  void _ensureCurrent(String accountId, int sessionEpoch) {
    if (!_sessionFence.isCurrent(
      accountId: accountId,
      sessionEpoch: sessionEpoch,
    )) {
      throw const GuestMigrationSessionChanged();
    }
  }

  /// 唯一編集可能なプロフィールフィールドを取り込みます。アカウントプロフィールにすでに
  /// ユーザー名がある場合はそれを優先し、ない場合はゲスト値を保持します。ゲスト行は
  /// 対応するアウトボックス変更と同じトランザクションで削除するため、成功後の再試行も安全です。
  Future<void> _migrateUserProfile(String accountId, String migrationId) async {
    await _userProfile.migrateGuestProfile(
      accountId: accountId,
      migrationId: migrationId,
    );
  }
}

class GuestMigrationSessionChanged implements Exception {
  const GuestMigrationSessionChanged();

  @override
  String toString() => 'Guest migration session changed';
}
