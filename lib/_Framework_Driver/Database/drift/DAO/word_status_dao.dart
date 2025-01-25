import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/word_status.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';

part '../../../../__generated/_Framework_Driver/Database/drift/DAO/word_status_dao.g.dart';

@DriftAccessor(tables: [WordStatus])
class WordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$WordStatusDaoMixin {
  WordStatusDao(super.database);
}
