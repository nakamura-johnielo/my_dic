import 'package:my_dic/core/shared/value_objects/field_update.dart';

class UpdateMyWordStatusInputData {
  final String wordId;
  final FieldUpdate<bool> isLearned;
  final FieldUpdate<bool> isBookmarked;
  final FieldUpdate<bool> hasNote;
  final String accountScope;

  UpdateMyWordStatusInputData(this.wordId, this.isLearned, this.isBookmarked,
      this.hasNote, this.accountScope);
}
