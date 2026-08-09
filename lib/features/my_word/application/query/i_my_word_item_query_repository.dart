import 'package:my_dic/features/my_word/application/query/my_word_item_projection.dart';

/// Application read port for one account-scoped MyWord projection.
abstract interface class IMyWordItemQueryRepository {
  Stream<MyWordItemProjection?> watchItem(
    String myWordId, {
    required String accountId,
  });
}
