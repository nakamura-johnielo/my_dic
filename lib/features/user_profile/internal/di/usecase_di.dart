import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/user_profile/internal/di/data_di.dart';
import 'package:my_dic/features/user_profile/internal/application/usecase/user_usecases.dart';

final getUserInteractorProvider = Provider<IGetUserUseCase>(
  (ref) => GetUserInteractor(ref.watch(userRepositoryProvider)),
);

final createNewUserInteractorProvider = Provider<ICreateNewUserUseCase>(
  (ref) => CreateNewUserInteractor(ref.watch(userRepositoryProvider)),
);

final updateUserInteractorProvider = Provider<IUpdateUserUseCase>(
  (ref) => UpdateUserInteractor(ref.watch(userRepositoryProvider)),
);
