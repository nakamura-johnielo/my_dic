import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/section/db_loading/database_loading_state.dart';
import 'package:my_dic/core/shared/enums/web/db.dart';

class DatabaseLoadingNotifier extends StateNotifier<DatabaseLoadingState> {
  DatabaseLoadingNotifier() : super(const DatabaseLoadingState());

  void updateProgress(double? progress, String? message, WebDBLoadingType? loadingType) {
    print("type: ${state.loadingType} ==========================");
    state = state.copyWith(
      isLoading: true,
      progress: progress!=null? (progress.isFinite
      ? progress.clamp(0.0, 1.0)
      : 0.0):null,
      message: message,
      loadingType: loadingType,
    );
  }

  void complete(String? message) {
    state = state.copyWith(
      isLoading: false,
      progress: 1.0,
      message: message ?? 'Complete',
    );
  }

  void reset() {
    state = const DatabaseLoadingState();
  }
}


