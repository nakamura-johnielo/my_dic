import 'package:my_dic/features/my_word/internal/application/model/my_word_item_projection.dart';

/// 1 つのアカウントスコープの MyWord プロジェクション用アプリケーション読み取りポート。
abstract interface class MyWordItemQuery {
  Stream<MyWordItemProjection?> watchItem(
    String myWordId, {
    required String accountId,
  });
}
