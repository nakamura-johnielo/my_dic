import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/user/di/data_di.dart';
import 'package:my_dic/features/user/domain/usecase/ensure_user_exists.dart';
import 'package:my_dic/features/user/domain/usecase/get_user.dart';
import 'package:my_dic/features/user/domain/usecase/update_user%20copy.dart';

final getUserInteractorProvider = Provider(
  (ref) => GetUserInteractor(ref.watch(firebaseUserRepositoryProvider)),
);

final updateUserInteractorProvider = Provider(
  (ref) => UpdateUserInteractor(ref.watch(firebaseUserRepositoryProvider)),
);

final ensureUserExistsInteractorProvider = Provider(
  (ref) =>
      EnsureUserExistsInteractor(ref.watch(firebaseUserRepositoryProvider)),
);
