import 'package:my_dic/core/shared/errors/app_error.dart';

/// クエリ応答を拡充する際に発生した、致命的ではない失敗。
///
/// [source] は失敗したクエリの関心事（例: `ranking` や `conjugation`）を識別します。
/// これはアプリケーション契約であり、ユーザー向け文言ではありません。
class QueryIssue {
  const QueryIssue({required this.source, required this.error});

  final String source;
  final AppError error;
}
