import 'package:my_dic/core/shared/errors/app_error.dart';

/// Internal marker used to distinguish an invalid persisted row from I/O.
final class WordStatusRecordCorruptionError extends AppError {
  const WordStatusRecordCorruptionError()
      : super(
          message: 'A persisted WordStatus row is invalid.',
          code: 'WORD_STATUS_RECORD_CORRUPT',
        );
}
