import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/port/result.dart';

/// 1 つのアカウントスコープにおける MyWord ID のページリクエスト。
final class LoadMyWordsQuery {
  const LoadMyWordsQuery({
    required this.size,
    required this.page,
    required this.accountScope,
  });

  final int size;
  final int page;
  final String accountScope;
}

/// 1 つの MyWord カードプロジェクションを監視するリクエスト。
final class WatchMyWordItemQuery {
  const WatchMyWordItemQuery({
    required this.myWordId,
    required this.accountScope,
  });

  final String myWordId;
  final String accountScope;
}

/// MyWord 集約が所有する読み取り操作。
abstract interface class MyWordQueryPort {
  Future<Result<List<String>>> loadIds(LoadMyWordsQuery query);

  Stream<MyWordItem?> watchItem(WatchMyWordItemQuery query);
}
