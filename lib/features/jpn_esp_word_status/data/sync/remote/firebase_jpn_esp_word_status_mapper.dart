import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';

class FirebaseJpnEspWordStatusMapper {
  static JpnEspWordStatusDTO fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return JpnEspWordStatusDTO(
      wordId: data[JpnEspWordStatusDTO.fieldwordId] as int,
      isLearned: data[JpnEspWordStatusDTO.fieldIsLearned] as int,
      isBookmarked: data[JpnEspWordStatusDTO.fieldIsBookmarked] as int,
      hasNote: data[JpnEspWordStatusDTO.fieldHasNote] as int,
      updateBy: data[JpnEspWordStatusDTO.fieldupdateBy] as String?,
      createdAt: (data[JpnEspWordStatusDTO.fieldCreatedAt] as Timestamp)
          .toDate()
          .toUtc(),
      updatedAt: (data[JpnEspWordStatusDTO.fieldUpdatedAt] as Timestamp)
          .toDate()
          .toUtc(),
      remoteRevision: data[JpnEspWordStatusDTO.fieldRevision] as int? ?? 0,
      lastMutationId: data[JpnEspWordStatusDTO.fieldLastMutationId] as String?,
      clientUpdatedAt:
          (data[JpnEspWordStatusDTO.fieldClientUpdatedAt] as Timestamp?)
              ?.toDate()
              .toUtc(),
    );
  }

  static Map<String, dynamic> toFirestore(JpnEspWordStatusDTO dto) => {
        JpnEspWordStatusDTO.fieldwordId: dto.wordId,
        JpnEspWordStatusDTO.fieldIsLearned: dto.isLearned,
        JpnEspWordStatusDTO.fieldIsBookmarked: dto.isBookmarked,
        JpnEspWordStatusDTO.fieldHasNote: dto.hasNote,
        JpnEspWordStatusDTO.fieldupdateBy: dto.updateBy,
        JpnEspWordStatusDTO.fieldCreatedAt:
            Timestamp.fromDate(dto.createdAt.toUtc()),
        JpnEspWordStatusDTO.fieldUpdatedAt:
            Timestamp.fromDate(dto.updatedAt.toUtc()),
        JpnEspWordStatusDTO.fieldRevision: dto.remoteRevision,
        JpnEspWordStatusDTO.fieldLastMutationId: dto.lastMutationId,
        if (dto.clientUpdatedAt != null)
          JpnEspWordStatusDTO.fieldClientUpdatedAt:
              Timestamp.fromDate(dto.clientUpdatedAt!.toUtc()),
      };
}
