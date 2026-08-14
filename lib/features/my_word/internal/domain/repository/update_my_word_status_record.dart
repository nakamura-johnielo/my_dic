import 'package:my_dic/core/shared/value_objects/field_update.dart';

final class UpdateMyWordStatusInputData {
  final String wordId;
  final FieldUpdate<bool> isLearned;
  final FieldUpdate<bool> isBookmarked;
  final FieldUpdate<bool> hasNote;
  DateTime editAt;
  final String? userId;

  factory UpdateMyWordStatusInputData(
    String wordId,
    Object? isLearned,
    Object? isBookmarked,
    Object? hasNote,
    DateTime editAt,
    String? userId,
  ) =>
      UpdateMyWordStatusInputData._(
        wordId,
        _asFieldUpdate(isLearned),
        _asFieldUpdate(isBookmarked),
        _asFieldUpdate(hasNote),
        editAt,
        userId,
      );

  UpdateMyWordStatusInputData._(
    this.wordId,
    this.isLearned,
    this.isBookmarked,
    this.hasNote,
    this.editAt,
    this.userId,
  );

  static FieldUpdate<bool> _asFieldUpdate(Object? value) => switch (value) {
        FieldUpdate<bool> update => update,
        true => const FieldUpdate.set(true),
        false => const FieldUpdate.set(false),
        1 => const FieldUpdate.set(true),
        0 => const FieldUpdate.set(false),
        _ => const FieldUpdate.unchanged(),
      };
}
