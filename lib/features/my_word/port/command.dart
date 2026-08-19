import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';

/// [accountScope] が所有する単語を作成するリクエスト。
final class RegisterMyWordCommand {
  const RegisterMyWordCommand({
    required this.headword,
    required this.description,
    required this.accountScope,
  });

  final String headword;
  final String description;
  final String accountScope;
}

/// 所有する 1 つの単語の編集可能な内容を置き換えるリクエスト。
final class UpdateMyWordCommand {
  const UpdateMyWordCommand({
    required this.myWordId,
    required this.headword,
    required this.description,
    required this.accountScope,
  });

  final String myWordId;
  final String headword;
  final String description;
  final String accountScope;
}

/// [accountScope] から 1 つの単語を削除するリクエスト。
final class DeleteMyWordCommand {
  const DeleteMyWordCommand({
    required this.myWordId,
    required this.accountScope,
  });

  final String myWordId;
  final String accountScope;
}

/// [accountScope] が所有する 1 つの単語の部分的なステータス更新。
final class UpdateMyWordStatusCommand {
  const UpdateMyWordStatusCommand({
    required this.myWordId,
    this.isLearned = const FieldUpdate.unchanged(),
    this.isBookmarked = const FieldUpdate.unchanged(),
    this.hasNote = const FieldUpdate.unchanged(),
    required this.accountScope,
  });

  final String myWordId;
  final FieldUpdate<bool> isLearned;
  final FieldUpdate<bool> isBookmarked;
  final FieldUpdate<bool> hasNote;
  final String accountScope;

  bool get hasChanges =>
      isLearned.isChanged || isBookmarked.isChanged || hasNote.isChanged;
}

/// MyWord 集約が所有する書き込み操作。
abstract interface class MyWordCommandPort {
  Future<Result<String>> register(RegisterMyWordCommand command);

  Future<Result<void>> update(UpdateMyWordCommand command);

  Future<Result<void>> delete(DeleteMyWordCommand command);
}

/// MyWord 集約が所有するステータス書き込み。
abstract interface class MyWordStatusCommandPort {
  Future<Result<void>> updateStatus(UpdateMyWordStatusCommand command);
}
