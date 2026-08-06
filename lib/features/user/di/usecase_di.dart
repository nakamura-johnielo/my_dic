import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/features/user/di/data_di.dart';
import 'package:my_dic/features/user/domain/usecase/create_new_user.dart';
import 'package:my_dic/features/user/domain/usecase/get_user.dart';
import 'package:my_dic/features/user/domain/usecase/i_create_new_user_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/update_user.dart';

final getUserInteractorProvider = Provider<IGetUserUseCase>(
  (ref) => GetUserInteractor(ref.watch(firebaseUserRepositoryProvider),
      ref.watch(currentSessionProvider)),
);

final createNewUserInteractorProvider = Provider<ICreateNewUserUseCase>(
  (ref) => CreateNewUserInteractor(ref.watch(firebaseUserRepositoryProvider),
      ref.watch(currentSessionProvider)),
);

final updateUserInteractorProvider = Provider<IUpdateUserUseCase>(
  (ref) => UpdateUserInteractor(ref.watch(firebaseUserRepositoryProvider),
      ref.watch(currentSessionProvider)),
);
