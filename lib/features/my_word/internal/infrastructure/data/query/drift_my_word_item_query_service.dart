import 'package:my_dic/features/my_word/internal/application/query/my_word_item_query.dart';
import 'package:my_dic/features/my_word/internal/application/model/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dao/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/mapper/my_word_infrastructure_error_mapper.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/mapper/my_word_item_projection_mapper.dart';

/// Drift-backed read adapter. It never writes a missing status row.
final class DriftMyWordItemQueryRepository implements MyWordItemQuery {
  DriftMyWordItemQueryRepository(this._dao);

  final MyWordDao _dao;

  @override
  Stream<MyWordItemProjection?> watchItem(
    String myWordId, {
    required String accountId,
  }) {
    return _dao
        .watchMyWordItemRow(myWordId, accountId)
        .map((row) =>
            row == null ? null : MyWordItemProjectionMapper.fromDriftRow(row))
        .handleError((Object error, StackTrace stackTrace) {
      throw MyWordInfrastructureErrorMapper.database(
        error,
        stackTrace,
        message: 'Failed to watch my word.',
      );
    }).distinct();
  }
}
