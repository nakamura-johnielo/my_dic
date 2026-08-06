import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/user/di/data_di.dart';
import 'package:my_dic/features/user/domain/usecase/ensure_user_exists.dart';
import 'package:my_dic/features/user/domain/usecase/i_ensure_user_exists_use_case.dart';

/// Kept in its own file, separate from `usecase_di.dart`, because
/// `auth_lifecycle_provider.dart` depends on this provider while
/// `usecase_di.dart` depends on `currentSessionProvider`, which itself is
/// derived from `authLifecycleProvider`. Importing both from one file would
/// create an import cycle.
final ensureUserExistsInteractorProvider = Provider<IEnsureUserExistsUseCase>(
  (ref) =>
      EnsureUserExistsInteractor(ref.watch(firebaseUserRepositoryProvider)),
);
