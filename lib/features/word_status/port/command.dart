import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/port/model/word_status_scope.dart';

/// 明示的なアカウントスコープ内での部分的なステータス変更です。
///
/// タイムスタンプは呼び出し元ではなくアプリケーションサービスが割り当てます。
final class UpdateWordStatusCommand {
  const UpdateWordStatusCommand({
    required this.scope,
    required this.word,
    this.isLearned = const FieldUpdate.unchanged(),
    this.isBookmarked = const FieldUpdate.unchanged(),
    this.hasNote = const FieldUpdate.unchanged(),
  });

  final WordStatusScope scope;
  final CatalogWordRef word;
  final FieldUpdate<bool> isLearned;
  final FieldUpdate<bool> isBookmarked;
  final FieldUpdate<bool> hasNote;

  bool get hasChanges =>
      isLearned.isChanged || isBookmarked.isChanged || hasNote.isChanged;
}

abstract interface class WordStatusCommandPort {
  Future<Result<void>> update(UpdateWordStatusCommand command);
}

/// 2 つの物理辞書方向に対するゲストスコープ行数です。
final class WordStatusGuestRowCounts {
  const WordStatusGuestRowCounts({required this.espJpn, required this.jpnEsp});

  final int espJpn;
  final int jpnEsp;
}

/// ゲストの辞書ステータス行を移行するアプリワークフロー機能です。
abstract interface class WordStatusGuestMigrationPort {
  Future<WordStatusGuestRowCounts> countGuestRows();

  Future<void> migrateGuestRows({
    required String accountId,
    required String migrationId,
    required DateTime Function() clock,
  });
}
