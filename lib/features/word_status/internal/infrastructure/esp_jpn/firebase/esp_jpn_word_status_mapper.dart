import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_dto.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';

final class EspJpnWordStatusMapper {
  const EspJpnWordStatusMapper._();

  static EspJpnWordStatusDto fromDocument(
    FirebaseAccountNestedDocument document,
  ) {
    final data = document.fields;
    return EspJpnWordStatusDto(
      wordId: data[EspJpnWordStatusDto.fieldWordId] as int,
      isLearned: data[EspJpnWordStatusDto.fieldIsLearned] as int,
      isBookmarked: data[EspJpnWordStatusDto.fieldIsBookmarked] as int,
      hasNote: data[EspJpnWordStatusDto.fieldHasNote] as int,
      updateBy: data[EspJpnWordStatusDto.fieldUpdateBy] as String?,
      createdAt: (data[EspJpnWordStatusDto.fieldCreatedAt] as DateTime).toUtc(),
      updatedAt: (data[EspJpnWordStatusDto.fieldUpdatedAt] as DateTime).toUtc(),
      remoteRevision: data[EspJpnWordStatusDto.fieldRevision] as int? ?? 0,
      lastMutationId: data[EspJpnWordStatusDto.fieldLastMutationId] as String?,
      clientUpdatedAt:
          (data[EspJpnWordStatusDto.fieldClientUpdatedAt] as DateTime?)?.toUtc(),
    );
  }

  static Map<String, Object?> toDocument(EspJpnWordStatusDto dto) => {
        EspJpnWordStatusDto.fieldWordId: dto.wordId,
        EspJpnWordStatusDto.fieldIsLearned: dto.isLearned,
        EspJpnWordStatusDto.fieldIsBookmarked: dto.isBookmarked,
        EspJpnWordStatusDto.fieldHasNote: dto.hasNote,
        EspJpnWordStatusDto.fieldUpdateBy: dto.updateBy,
        EspJpnWordStatusDto.fieldCreatedAt:
            dto.createdAt.toUtc(),
        EspJpnWordStatusDto.fieldUpdatedAt:
            dto.updatedAt.toUtc(),
        EspJpnWordStatusDto.fieldRevision: dto.remoteRevision,
        EspJpnWordStatusDto.fieldLastMutationId: dto.lastMutationId,
        if (dto.clientUpdatedAt != null)
          EspJpnWordStatusDto.fieldClientUpdatedAt:
              dto.clientUpdatedAt!.toUtc(),
      };
}
