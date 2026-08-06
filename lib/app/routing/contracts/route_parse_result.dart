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
