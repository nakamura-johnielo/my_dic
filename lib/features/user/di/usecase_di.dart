import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/user/di/data_di.dart';
import 'package:my_dic/features/user/domain/usecase/ensure_user_exists.dart';
import 'package:my_dic/features/user/domain/usecase/get_user.dart';
import 'package:my_dic/features/user/domain/usecase/i_ensure_user_exists_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/update_user.dart';

final getUserInteractorProvider = Provider<IGetUserUseCase>(
  (ref) => GetUserInteractor(ref.watch(firebaseUserRepositoryProvider)),
);

final updateUserInteractorProvider = Provider<IUpdateUserUseCase>(
  (ref) => UpdateUserInteractor(ref.watch(firebaseUserRepositoryProvider)),
);

final ensureUserExistsInteractorProvider = Provider<IEnsureUserExistsUseCase>(
  (ref) =>
      EnsureUserExistsInteractor(ref.watch(firebaseUserRepositoryProvider)),
);
