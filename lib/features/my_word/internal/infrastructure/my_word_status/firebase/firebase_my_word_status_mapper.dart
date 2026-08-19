import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dto.dart';

/// MyWordStatus データセットにおける、唯一の Firestore からワイヤ形式へのマッピング。
final class FirebaseMyWordStatusMapper {
  const FirebaseMyWordStatusMapper._();

  static MyWordStatusDTO fromDocument(
    FirebaseAccountNestedDocument document,
  ) {
    final data = document.fields;
    return MyWordStatusDTO(
      myWordId: data[MyWordStatusDTO.fieldMyWordId] as String,
      isLearned: data[MyWordStatusDTO.fieldIsLearned] as int,
      isBookmarked: data[MyWordStatusDTO.fieldIsBookmarked] as int,
      updateBy: data[MyWordStatusDTO.fieldUpdateBy] as String?,
      createdAt: (data[MyWordStatusDTO.fieldCreatedAt] as DateTime).toUtc(),
      updatedAt: (data[MyWordStatusDTO.fieldUpdatedAt] as DateTime).toUtc(),
      remoteRevision: data[MyWordStatusDTO.fieldRevision] as int? ?? 0,
      lastMutationId: data[MyWordStatusDTO.fieldLastMutationId] as String?,
      clientUpdatedAt:
          (data[MyWordStatusDTO.fieldClientUpdatedAt] as DateTime?)?.toUtc(),
    );
  }
}
