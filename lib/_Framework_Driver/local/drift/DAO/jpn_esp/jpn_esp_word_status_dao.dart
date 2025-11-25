import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/local/drift/Entity/jpn-esp/jpn_esp_word_status.dart';
import 'package:my_dic/_Framework_Driver/local/drift/database_provider.dart';

part '../../../../../__generated/_Framework_Driver/Database/drift/DAO/jpn_esp/jpn_esp_word_status_dao.g.dart';

@DriftAccessor(tables: [JpnEspWordStatus])
class JpnEspWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspWordStatusDaoMixin {
  JpnEspWordStatusDao(super.database);
}
