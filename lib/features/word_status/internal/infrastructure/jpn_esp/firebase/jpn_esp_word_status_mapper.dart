import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/jpn_esp_word_status_dto.dart';

final class JpnEspWordStatusMapper {
  const JpnEspWordStatusMapper._();

  static JpnEspWordStatusDto fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return JpnEspWordStatusDto(
      wordId: data[JpnEspWordStatusDto.fieldWordId] as int,
      isLearned: data[JpnEspWordStatusDto.fieldIsLearned] as int,
      isBookmarked: data[JpnEspWordStatusDto.fieldIsBookmarked] as int,
      hasNote: data[JpnEspWordStatusDto.fieldHasNote] as int,
      updateBy: data[JpnEspWordStatusDto.fieldUpdateBy] as String?,
      createdAt: (data[JpnEspWordStatusDto.fieldCreatedAt] as Timestamp)
          .toDate()
          .toUtc(),
      updatedAt: (data[JpnEspWordStatusDto.fieldUpdatedAt] as Timestamp)
          .toDate()
          .toUtc(),
      remoteRevision: data[JpnEspWordStatusDto.fieldRevision] as int? ?? 0,
      lastMutationId: data[JpnEspWordStatusDto.fieldLastMutationId] as String?,
      clientUpdatedAt:
          (data[JpnEspWordStatusDto.fieldClientUpdatedAt] as Timestamp?)
              ?.toDate()
              .toUtc(),
    );
  }

  static Map<String, dynamic> toFirestore(JpnEspWordStatusDto dto) => {
        JpnEspWordStatusDto.fieldWordId: dto.wordId,
        JpnEspWordStatusDto.fieldIsLearned: dto.isLearned,
        JpnEspWordStatusDto.fieldIsBookmarked: dto.isBookmarked,
        JpnEspWordStatusDto.fieldHasNote: dto.hasNote,
        JpnEspWordStatusDto.fieldUpdateBy: dto.updateBy,
        JpnEspWordStatusDto.fieldCreatedAt:
            Timestamp.fromDate(dto.createdAt.toUtc()),
        JpnEspWordStatusDto.fieldUpdatedAt:
            Timestamp.fromDate(dto.updatedAt.toUtc()),
        JpnEspWordStatusDto.fieldRevision: dto.remoteRevision,
        JpnEspWordStatusDto.fieldLastMutationId: dto.lastMutationId,
        if (dto.clientUpdatedAt != null)
          JpnEspWordStatusDto.fieldClientUpdatedAt:
              Timestamp.fromDate(dto.clientUpdatedAt!.toUtc()),
      };
}
