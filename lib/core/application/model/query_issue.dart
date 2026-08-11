import 'package:my_dic/core/shared/errors/app_error.dart';

/// A non-fatal failure encountered while enriching a query response.
///
/// [source] identifies the failed query concern (for example, `ranking` or
/// `conjugation`). It is an application contract, not user-facing copy.
class QueryIssue {
  const QueryIssue({required this.source, required this.error});

  final String source;
  final AppError error;
}
