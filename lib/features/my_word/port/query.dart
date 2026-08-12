import 'package:my_dic/features/my_word/port/result.dart';

/// A page request for MyWord IDs in one account scope.
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

/// A request to watch one MyWord card projection.
final class WatchMyWordItemQuery {
  const WatchMyWordItemQuery({
    required this.myWordId,
    required this.accountScope,
  });

  final String myWordId;
  final String accountScope;
}

/// Read operations owned by the MyWord aggregate.
abstract interface class MyWordReaderPort {
  Future<Result<List<String>>> loadIds(LoadMyWordsQuery query);

  Stream<MyWordItem?> watchItem(WatchMyWordItemQuery query);
}
