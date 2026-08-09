import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_dto.dart';

final class EspJpnWordStatusMapper {
  const EspJpnWordStatusMapper._();

  static EspJpnWordStatusDto fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return EspJpnWordStatusDto(
      wordId: data[EspJpnWordStatusDto.fieldWordId] as int,
      isLearned: data[EspJpnWordStatusDto.fieldIsLearned] as int,
      isBookmarked: data[EspJpnWordStatusDto.fieldIsBookmarked] as int,
      hasNote: data[EspJpnWordStatusDto.fieldHasNote] as int,
      updateBy: data[EspJpnWordStatusDto.fieldUpdateBy] as String?,
      createdAt: (data[EspJpnWordStatusDto.fieldCreatedAt] as Timestamp)
          .toDate()
          .toUtc(),
      updatedAt: (data[EspJpnWordStatusDto.fieldUpdatedAt] as Timestamp)
          .toDate()
          .toUtc(),
      remoteRevision: data[EspJpnWordStatusDto.fieldRevision] as int? ?? 0,
      lastMutationId: data[EspJpnWordStatusDto.fieldLastMutationId] as String?,
      clientUpdatedAt:
          (data[EspJpnWordStatusDto.fieldClientUpdatedAt] as Timestamp?)
              ?.toDate()
              .toUtc(),
    );
  }

  static Map<String, dynamic> toFirestore(EspJpnWordStatusDto dto) => {
        EspJpnWordStatusDto.fieldWordId: dto.wordId,
        EspJpnWordStatusDto.fieldIsLearned: dto.isLearned,
        EspJpnWordStatusDto.fieldIsBookmarked: dto.isBookmarked,
        EspJpnWordStatusDto.fieldHasNote: dto.hasNote,
        EspJpnWordStatusDto.fieldUpdateBy: dto.updateBy,
        EspJpnWordStatusDto.fieldCreatedAt:
            Timestamp.fromDate(dto.createdAt.toUtc()),
        EspJpnWordStatusDto.fieldUpdatedAt:
            Timestamp.fromDate(dto.updatedAt.toUtc()),
        EspJpnWordStatusDto.fieldRevision: dto.remoteRevision,
        EspJpnWordStatusDto.fieldLastMutationId: dto.lastMutationId,
        if (dto.clientUpdatedAt != null)
          EspJpnWordStatusDto.fieldClientUpdatedAt:
              Timestamp.fromDate(dto.clientUpdatedAt!.toUtc()),
      };
}
