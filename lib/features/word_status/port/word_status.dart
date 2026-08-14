/// The sole business-facing import for WordStatus.
library;

export 'package:my_dic/core/shared/utils/result.dart'
    show Failure, Result, Success;
export 'package:my_dic/core/shared/value_objects/field_update.dart'
    show FieldUpdate, SetValue, Unchanged;
export 'package:my_dic/features/catalog/port/catalog.dart'
    show CatalogId, CatalogWordRef;
export 'command.dart';
export 'error.dart';
export 'model/word_status.dart';
export 'model/word_status_scope.dart';
export 'query.dart';
export 'result.dart';
