/// 機能が所有するルート契約を解析した結果。
///
/// 機能のルートポートをGoRouterに依存せずアプリルーターから利用できるよう、
/// 意図的にフレームワークに依存しない設計にしています。
sealed class RouteParseResult<T> {
  const RouteParseResult();
}

final class RouteParseSuccess<T> extends RouteParseResult<T> {
  const RouteParseSuccess(this.value);

  final T value;
}

final class RouteParseFailure<T> extends RouteParseResult<T> {
  const RouteParseFailure(this.message);

  final String message;
}
