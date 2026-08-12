import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';

/// The only Firestore-to-wire mapping for the MyWord dataset.
final class FirebaseMyWordMapper {
  const FirebaseMyWordMapper._();

  static MyWordDTO fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final deletedAt = data[MyWordDTO.fieldDeletedAt];
    return MyWordDTO(
      myWordId: data[MyWordDTO.fieldMyWordId] as String,
      word: data[MyWordDTO.fieldMyWord] as String,
      contents: data[MyWordDTO.fieldContents] as String,
      updateBy: data[MyWordDTO.fieldupdateBy] as String?,
      createdAt: (data[MyWordDTO.fieldCreatedAt] as Timestamp).toDate().toUtc(),
      updatedAt: (data[MyWordDTO.fieldUpdatedAt] as Timestamp).toDate().toUtc(),
      deletedAt: deletedAt is Timestamp ? deletedAt.toDate().toUtc() : null,
      remoteRevision: data[MyWordDTO.fieldRevision] as int? ?? 0,
      lastMutationId: data[MyWordDTO.fieldLastMutationId] as String?,
      clientUpdatedAt: (data[MyWordDTO.fieldClientUpdatedAt] as Timestamp?)
          ?.toDate()
          .toUtc(),
    );
  }
}
