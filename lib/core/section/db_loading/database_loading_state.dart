

import 'package:my_dic/core/shared/enums/web/db.dart';

class DatabaseLoadingState {
  final bool isLoading;
  final WebDBLoadingType loadingType;
  final double progress; // 0.0 ~ 1.0
  final String message;

  const DatabaseLoadingState({
    this.isLoading = false,
    this.progress = 0.0,
    this.message = '',  this.loadingType=WebDBLoadingType.download,
  });

  DatabaseLoadingState copyWith({
    bool? isLoading,
    double? progress,
    String? message,
    WebDBLoadingType? loadingType,
  }) {
    return DatabaseLoadingState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      loadingType: loadingType ?? this.loadingType,
    );
  }
}