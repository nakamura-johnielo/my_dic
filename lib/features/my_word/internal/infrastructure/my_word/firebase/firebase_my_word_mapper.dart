import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';

/// The only Firestore-to-wire mapping for the MyWord dataset.
final class FirebaseMyWordMapper {
  const FirebaseMyWordMapper._();

  static MyWordDTO fromDocument(FirebaseAccountNestedDocument document) {
    final data = document.fields;
    final deletedAt = data[MyWordDTO.fieldDeletedAt];
    return MyWordDTO(
      myWordId: data[MyWordDTO.fieldMyWordId] as String,
      word: data[MyWordDTO.fieldMyWord] as String,
      contents: data[MyWordDTO.fieldContents] as String,
      updateBy: data[MyWordDTO.fieldupdateBy] as String?,
      createdAt: (data[MyWordDTO.fieldCreatedAt] as DateTime).toUtc(),
      updatedAt: (data[MyWordDTO.fieldUpdatedAt] as DateTime).toUtc(),
      deletedAt: deletedAt is DateTime ? deletedAt.toUtc() : null,
      remoteRevision: data[MyWordDTO.fieldRevision] as int? ?? 0,
      lastMutationId: data[MyWordDTO.fieldLastMutationId] as String?,
      clientUpdatedAt:
          (data[MyWordDTO.fieldClientUpdatedAt] as DateTime?)?.toUtc(),
    );
  }
}
