import 'package:my_dic/core/shared/errors/app_error.dart';

/// 無効な永続化行と I/O を区別するための内部マーカーです。
final class WordStatusRecordCorruptionError extends AppError {
  const WordStatusRecordCorruptionError()
      : super(
          message: 'A persisted WordStatus row is invalid.',
          code: 'WORD_STATUS_RECORD_CORRUPT',
        );
}
