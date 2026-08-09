import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/word_status/application/port/word_status_guest_migration.dart';

import 'guest_data_summary.dart';

/// Reports whether any local row still sits under the guest scope, across
/// every dataset that supports real per-account scoping.
class DetectGuestDataUseCase {
  DetectGuestDataUseCase({
    required WordStatusGuestMigration wordStatus,
    required IMyWordLocalDataSource myWord,
    required IMyWordStatusLocalDataSource myWordStatus,
    required IUserProfileLocalDataSource userProfile,
  })  : _wordStatus = wordStatus,
        _myWord = myWord,
        _myWordStatus = myWordStatus,
        _userProfile = userProfile;

  final WordStatusGuestMigration _wordStatus;
  final IMyWordLocalDataSource _myWord;
  final IMyWordStatusLocalDataSource _myWordStatus;
  final IUserProfileLocalDataSource _userProfile;

  Future<GuestDataSummary> execute() async {
    final wordStatus = await _wordStatus.countGuestRows();
    final myWords = await _myWord.getAllByAccountId(guestAccountScope);
    final myWordStatuses =
        await _myWordStatus.getAllByAccountId(guestAccountScope);
    final userProfile = await _userProfile.getProfile(guestAccountScope);

    return GuestDataSummary(
      espJpnWordStatusCount: wordStatus.espJpn,
      jpnEspWordStatusCount: wordStatus.jpnEsp,
      myWordCount: myWords.length,
      myWordStatusCount: myWordStatuses.length,
      userProfileCount: userProfile == null ? 0 : 1,
    );
  }
}
