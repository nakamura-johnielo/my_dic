import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/features/user/di/data_di.dart';
import 'package:my_dic/features/user/application/usecase/user_usecases.dart';

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
