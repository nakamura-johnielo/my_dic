import 'package:my_dic/core/shared/value_objects/field_update.dart';

class UpdateJpnEspStatusInputData {
  final int wordId;
  final FieldUpdate<bool> isLearned;
  final FieldUpdate<bool> isBookmarked;
  final FieldUpdate<bool> hasNote;

  const UpdateJpnEspStatusInputData({
    required this.wordId,
    this.isLearned = const FieldUpdate.unchanged(),
    this.isBookmarked = const FieldUpdate.unchanged(),
    this.hasNote = const FieldUpdate.unchanged(),
  });

  bool get hasChanges =>
      isLearned.isChanged || isBookmarked.isChanged || hasNote.isChanged;
}
