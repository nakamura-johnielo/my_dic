import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/auth/domain/usecase/i_reload_current_auth_use_case.dart';

class ReloadCurrentAuthInteractor implements IReloadCurrentAuthUseCase {
  final IAuthRepository _authRepository;

  ReloadCurrentAuthInteractor(this._authRepository);

  @override
  Future<Result<AppAuth>> execute() => _authRepository.reloadCurrentAuth();
}
