import 'package:my_dic/core/shared/errors/app_error.dart';

/// A non-fatal failure for supplemental data displayed with a query result.
///
/// [source] is a presentation/application contract such as `ranking` or
/// `conjugation`; it deliberately is not user-facing copy.
class QueryWarning {
  const QueryWarning({required this.source, required this.error});

  final String source;
  final AppError error;
}

/// The lifecycle of a screen-level read operation.
sealed class QueryState<T> {
  const QueryState();

  const factory QueryState.initial() = QueryInitial<T>;
  const factory QueryState.loading({T? previousData}) = QueryLoading<T>;
  factory QueryState.data(T value, {List<QueryWarning> warnings}) =
      QueryData<T>;
  factory QueryState.empty({List<QueryWarning> warnings}) = QueryEmpty<T>;
  const factory QueryState.failure(AppError error, {T? previousData}) =
      QueryFailure<T>;

  /// Data safe to keep on screen while a refresh or pagination request runs.
  T? get previousDataOrNull => switch (this) {
        QueryLoading<T>(previousData: final data) => data,
        QueryFailure<T>(previousData: final data) => data,
        _ => null,
      };

  /// Data currently suitable for display, including stale data during reloads.
  T? get dataOrNull => switch (this) {
        QueryData<T>(value: final value) => value,
        _ => previousDataOrNull,
      };

  List<QueryWarning> get warnings => switch (this) {
        QueryData<T>(warnings: final warnings) => warnings,
        QueryEmpty<T>(warnings: final warnings) => warnings,
        _ => const [],
      };

  bool get hasData => dataOrNull != null;
  bool get hasPreviousData => previousDataOrNull != null;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isInitial => this is QueryInitial<T>;
  bool get isLoading => this is QueryLoading<T>;
  bool get isInitialLoading => this is QueryLoading<T> && !hasPreviousData;
  bool get isRefreshing => this is QueryLoading<T> && hasPreviousData;
  bool get isData => this is QueryData<T>;
  bool get isEmpty => this is QueryEmpty<T>;
  bool get isFailure => this is QueryFailure<T>;
}

final class QueryInitial<T> extends QueryState<T> {
  const QueryInitial();
}

final class QueryLoading<T> extends QueryState<T> {
  const QueryLoading({this.previousData});

  final T? previousData;
}

final class QueryData<T> extends QueryState<T> {
  QueryData(this.value, {List<QueryWarning> warnings = const []})
      : warnings = List.unmodifiable(warnings);

  final T value;

  @override
  final List<QueryWarning> warnings;
}

final class QueryEmpty<T> extends QueryState<T> {
  QueryEmpty({List<QueryWarning> warnings = const []})
      : warnings = List.unmodifiable(warnings);

  @override
  final List<QueryWarning> warnings;
}

final class QueryFailure<T> extends QueryState<T> {
  const QueryFailure(this.error, {this.previousData});

  final AppError error;
  final T? previousData;
}
