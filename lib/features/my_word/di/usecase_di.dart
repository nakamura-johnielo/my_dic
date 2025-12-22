import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/di/data_di.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_interactor.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/handle_word_registration/handle_word_registration_interactor.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/handle_word_registration/i_handle_word_registration_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_interactor.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_interactor.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_interactor.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_interactor.dart';


// ============================================================================
// UseCase Providers
// ============================================================================


final loadMyWordUseCaseProvider = Provider<ILoadMyWordUseCase>((ref) {
  return LoadMyWordInteractor(
    ref.read(myWordRepositoryProvider),
  );
});

final updateMyWordStatusUseCaseProvider =
    Provider<IUpdateMyWordStatusUseCase>((ref) {
  return UpdateMyWordStatusInteractor(
    ref.read(myWordRepositoryProvider),
  );
});

final registerMyWordUseCaseProvider = Provider<IRegisterMyWordUseCase>((ref) {
  return RegisterMyWordInteractor(
    ref.read(myWordRepositoryProvider),
  );
});

final handleWordRegistrationUseCaseProvider =
    Provider<IHandleWordRegistrationUseCase>((ref) {
  return HandleWordRegistrationInteractor();
});

final updateMyWordUseCaseProvider = Provider<IUpdateMyWordUseCase>((ref) {
  return UpdateMyWordInteractor(
    ref.read(myWordRepositoryProvider),
  );
});

final deleteMyWordUseCaseProvider = Provider<IDeleteMyWordUseCase>((ref) {
  return DeleteMyWordInteractor(
    ref.read(myWordRepositoryProvider),
  );
});
