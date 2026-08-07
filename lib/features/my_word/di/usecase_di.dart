import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/features/my_word/di/data_di.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/load_my_word/load_my_word_interactor.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/delete/delete_my_word/delete_my_word_interactor.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/create/register_my_word/register_my_word_interactor.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/update/update_my_word/update_my_word_interactor.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/watch/watch_my_word_interactor.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/watch/watch_my_word_usecase.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word_status/update_my_word_status/update_my_word_status_interactor.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word_status/watch_my_word_status/watch_my_word_status_usecase.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word_status/watch_my_word_status/watch_my_word_status_interactor.dart';

// ============================================================================
// UseCase Providers
// ============================================================================

final loadMyWordUseCaseProvider = Provider<ILoadMyWordUseCase>((ref) {
  return LoadMyWordInteractor(
    ref.read(myWordRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

final updateMyWordStatusUseCaseProvider =
    Provider<IUpdateMyWordStatusUseCase>((ref) {
  return UpdateMyWordStatusInteractor(
    ref.read(myWordStatusRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

final registerMyWordUseCaseProvider = Provider<IRegisterMyWordUseCase>((ref) {
  return RegisterMyWordInteractor(
    ref.read(myWordRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

final updateMyWordUseCaseProvider = Provider<IUpdateMyWordUseCase>((ref) {
  return UpdateMyWordInteractor(
    ref.read(myWordRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

final deleteMyWordUseCaseProvider = Provider<IDeleteMyWordUseCase>((ref) {
  return DeleteMyWordInteractor(
    ref.read(myWordRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

final watchMyWordStatusUseCaseProvider =
    Provider<WatchMyWordStatusUsecase>((ref) {
  return WatchMyWordStatusInteractor(
    ref.read(myWordStatusRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});

final watchMyWordUseCaseProvider = Provider<WatchMyWordUsecase>((ref) {
  return WatchMyWordInteractor(
    ref.read(myWordRepositoryProvider),
    ref.watch(currentSessionProvider),
  );
});
