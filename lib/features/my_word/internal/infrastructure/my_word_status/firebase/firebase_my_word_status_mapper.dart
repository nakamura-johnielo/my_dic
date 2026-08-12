import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dto.dart';

/// The only Firestore-to-wire mapping for the MyWordStatus dataset.
final class FirebaseMyWordStatusMapper {
  const FirebaseMyWordStatusMapper._();

  static MyWordStatusDTO fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MyWordStatusDTO(
      myWordId: data[MyWordStatusDTO.fieldMyWordId] as String,
      isLearned: data[MyWordStatusDTO.fieldIsLearned] as int,
      isBookmarked: data[MyWordStatusDTO.fieldIsBookmarked] as int,
      updateBy: data[MyWordStatusDTO.fieldUpdateBy] as String?,
      createdAt:
          (data[MyWordStatusDTO.fieldCreatedAt] as Timestamp).toDate().toUtc(),
      updatedAt:
          (data[MyWordStatusDTO.fieldUpdatedAt] as Timestamp).toDate().toUtc(),
      remoteRevision: data[MyWordStatusDTO.fieldRevision] as int? ?? 0,
      lastMutationId: data[MyWordStatusDTO.fieldLastMutationId] as String?,
      clientUpdatedAt:
          (data[MyWordStatusDTO.fieldClientUpdatedAt] as Timestamp?)
              ?.toDate()
              .toUtc(),
    );
  }
}
