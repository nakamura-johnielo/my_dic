import 'package:my_dic/features/user/data/dto/user_dto.dart';

abstract class IUserRemoteDataSource {
  Future<UserDTO?> getUserById(String id);

  Future<void> updateUser(UserDTO user);

  Future<void> createUser(UserDTO user);

  Future<UserDTO> ensureUser(UserDTO user);

  /// Writes only the fields named in [fieldMask], leaving every other remote
  /// field (including authorization fields) untouched. [isNew] controls
  /// whether `createdAt` is also stamped.
  Future<void> patchUser(
    String accountId,
    Map<String, Object?> fields,
    List<String> fieldMask, {
    required bool isNew,
  });
}
