import 'package:my_dic/core/shared/value_objects/field_update.dart';

class UpdateJpnEspStatusRepositoryInputData {
  final int wordId;
  final FieldUpdate<bool> isLearned;
  final FieldUpdate<bool> isBookmarked;
  final FieldUpdate<bool> hasNote;

  const UpdateJpnEspStatusRepositoryInputData({
    required this.wordId,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
  });
}
