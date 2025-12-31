import 'package:my_dic/features/user/domain/entity/user.dart';

abstract interface class IUpdateUserUseCase {
  Future<void> execute(AppUser user);
}
