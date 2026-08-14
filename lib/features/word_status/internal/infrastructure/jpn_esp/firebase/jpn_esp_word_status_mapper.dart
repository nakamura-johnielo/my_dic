import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/jpn_esp_word_status_dto.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';

final class JpnEspWordStatusMapper {
  const JpnEspWordStatusMapper._();

  static JpnEspWordStatusDto fromDocument(
    FirebaseAccountNestedDocument document,
  ) {
    final data = document.fields;
    return JpnEspWordStatusDto(
      wordId: data[JpnEspWordStatusDto.fieldWordId] as int,
      isLearned: data[JpnEspWordStatusDto.fieldIsLearned] as int,
      isBookmarked: data[JpnEspWordStatusDto.fieldIsBookmarked] as int,
      hasNote: data[JpnEspWordStatusDto.fieldHasNote] as int,
      updateBy: data[JpnEspWordStatusDto.fieldUpdateBy] as String?,
      createdAt: (data[JpnEspWordStatusDto.fieldCreatedAt] as DateTime).toUtc(),
      updatedAt: (data[JpnEspWordStatusDto.fieldUpdatedAt] as DateTime).toUtc(),
      remoteRevision: data[JpnEspWordStatusDto.fieldRevision] as int? ?? 0,
      lastMutationId: data[JpnEspWordStatusDto.fieldLastMutationId] as String?,
      clientUpdatedAt:
          (data[JpnEspWordStatusDto.fieldClientUpdatedAt] as DateTime?)?.toUtc(),
    );
  }

  static Map<String, Object?> toDocument(JpnEspWordStatusDto dto) => {
        JpnEspWordStatusDto.fieldWordId: dto.wordId,
        JpnEspWordStatusDto.fieldIsLearned: dto.isLearned,
        JpnEspWordStatusDto.fieldIsBookmarked: dto.isBookmarked,
        JpnEspWordStatusDto.fieldHasNote: dto.hasNote,
        JpnEspWordStatusDto.fieldUpdateBy: dto.updateBy,
        JpnEspWordStatusDto.fieldCreatedAt:
            dto.createdAt.toUtc(),
        JpnEspWordStatusDto.fieldUpdatedAt:
            dto.updatedAt.toUtc(),
        JpnEspWordStatusDto.fieldRevision: dto.remoteRevision,
        JpnEspWordStatusDto.fieldLastMutationId: dto.lastMutationId,
        if (dto.clientUpdatedAt != null)
          JpnEspWordStatusDto.fieldClientUpdatedAt:
              dto.clientUpdatedAt!.toUtc(),
      };
}
