import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/usecase/i_observe_auth_state_use_case.dart';

class ObserveAuthStateInteractor implements IObserveAuthStateUseCase {
  final IAuthRepository _repo;
  ObserveAuthStateInteractor(this._repo);

  @override
  Stream<AppAuth?> execute() {
    final authStateStream = _repo.observeAuthState();
    return authStateStream;
  }
}
