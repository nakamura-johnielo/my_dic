import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/my_word/port/result.dart';

/// A request to create a word owned by [accountScope].
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

/// A request to replace the editable contents of one owned word.
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

/// A request to delete one word from [accountScope].
final class DeleteMyWordCommand {
  const DeleteMyWordCommand({
    required this.myWordId,
    required this.accountScope,
  });

  final String myWordId;
  final String accountScope;
}

/// A partial status update for one word owned by [accountScope].
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

/// Write operations owned by the MyWord aggregate.
abstract interface class MyWordCommandPort {
  Future<Result<String>> register(RegisterMyWordCommand command);

  Future<Result<void>> update(UpdateMyWordCommand command);

  Future<Result<void>> delete(DeleteMyWordCommand command);
}

/// Status writes owned by the MyWord aggregate.
abstract interface class MyWordStatusCommandPort {
  Future<Result<void>> updateStatus(UpdateMyWordStatusCommand command);
}
