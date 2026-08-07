import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';

class MyWordStatusState {
  final QueryState<MyWordStatus> status;

  const MyWordStatusState({required this.status});

  bool get isLearned => status.dataOrNull?.isLearned ?? false;
  bool get isBookmarked => status.dataOrNull?.isBookmarked ?? false;

  MyWordStatusState copyWith({
    QueryState<MyWordStatus>? status,
  }) {
    return MyWordStatusState(
      status: status ?? this.status,
    );
  }

  factory MyWordStatusState.fromAsync(AsyncValue<MyWordStatus> async) {
    return async.when(
      data: (status) => MyWordStatusState(status: QueryState.data(status)),
      loading: () => MyWordStatusState(
        status: QueryState.loading(previousData: async.valueOrNull),
      ),
      error: (error, _) => MyWordStatusState(
        status: QueryState.failure(_asAppError(error),
            previousData: async.valueOrNull),
      ),
    );
  }
}

AppError _asAppError(Object error) => error is AppError
    ? error
    : UnexpectedError(
        message: 'Unable to load word status.', originalError: error);
