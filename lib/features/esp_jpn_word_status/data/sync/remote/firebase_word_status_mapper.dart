import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/word_status_entity.dart';

class FirebaseWordStatusMapper {
  static WordStatusDTO fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return WordStatusDTO(
      wordId: data[WordStatusDTO.fieldwordId] as int,
      isLearned: data[WordStatusDTO.fieldIsLearned] as int,
      isBookmarked: data[WordStatusDTO.fieldIsBookmarked] as int,
      hasNote: data[WordStatusDTO.fieldHasNote] as int,
      updateBy: data[WordStatusDTO.fieldupdateBy] as String?,
      createdAt:
          (data[WordStatusDTO.fieldCreatedAt] as Timestamp).toDate().toUtc(),
      updatedAt:
          (data[WordStatusDTO.fieldUpdatedAt] as Timestamp).toDate().toUtc(),
      remoteRevision: data[WordStatusDTO.fieldRevision] as int? ?? 0,
      lastMutationId: data[WordStatusDTO.fieldLastMutationId] as String?,
      clientUpdatedAt: (data[WordStatusDTO.fieldClientUpdatedAt] as Timestamp?)
          ?.toDate()
          .toUtc(),
    );
  }

  static Map<String, dynamic> toFirestore(WordStatusDTO dto) => {
        WordStatusDTO.fieldwordId: dto.wordId,
        WordStatusDTO.fieldIsLearned: dto.isLearned,
        WordStatusDTO.fieldIsBookmarked: dto.isBookmarked,
        WordStatusDTO.fieldHasNote: dto.hasNote,
        WordStatusDTO.fieldupdateBy: dto.updateBy,
        WordStatusDTO.fieldCreatedAt: Timestamp.fromDate(dto.createdAt.toUtc()),
        WordStatusDTO.fieldUpdatedAt: Timestamp.fromDate(dto.updatedAt.toUtc()),
        WordStatusDTO.fieldRevision: dto.remoteRevision,
        WordStatusDTO.fieldLastMutationId: dto.lastMutationId,
        if (dto.clientUpdatedAt != null)
          WordStatusDTO.fieldClientUpdatedAt:
              Timestamp.fromDate(dto.clientUpdatedAt!.toUtc()),
      };
}
