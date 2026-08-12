import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

/// A partial mutation requested for a dictionary word status.
final class UpdateWordStatusCommand {
  const UpdateWordStatusCommand({
    required this.word,
    this.isLearned = const FieldUpdate.unchanged(),
    this.isBookmarked = const FieldUpdate.unchanged(),
    this.hasNote = const FieldUpdate.unchanged(),
  });

  final CatalogWordRef word;
  final FieldUpdate<bool> isLearned;
  final FieldUpdate<bool> isBookmarked;
  final FieldUpdate<bool> hasNote;

  bool get hasChanges =>
      isLearned.isChanged || isBookmarked.isChanged || hasNote.isChanged;
}
