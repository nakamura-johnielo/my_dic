/// The result of parsing a feature-owned route contract.
///
/// This is deliberately framework-free so feature route ports can be used by
/// the app router without depending on GoRouter.
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
