import 'package:my_dic/features/my_word/port/my_word.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

import 'guest_data_summary.dart';

/// Reports whether any local row still sits under the guest scope, across
/// every dataset that supports real per-account scoping.
class DetectGuestDataUseCase {
  DetectGuestDataUseCase({
    required WordStatusGuestMigrationPort wordStatus,
    required MyWordGuestMigrationPort myWord,
    required UserProfileGuestMigrationPort userProfile,
  })  : _wordStatus = wordStatus,
        _myWord = myWord,
        _userProfile = userProfile;

  final WordStatusGuestMigrationPort _wordStatus;
  final MyWordGuestMigrationPort _myWord;
  final UserProfileGuestMigrationPort _userProfile;

  Future<GuestDataSummary> execute() async {
    final wordStatus = await _wordStatus.countGuestRows();
    final myWord = await _myWord.countGuestRows();
    final userProfile = await _userProfile.hasGuestProfile();

    return GuestDataSummary(
      espJpnWordStatusCount: wordStatus.espJpn,
      jpnEspWordStatusCount: wordStatus.jpnEsp,
      myWordCount: myWord.words,
      myWordStatusCount: myWord.statuses,
      userProfileCount: userProfile ? 1 : 0,
    );
  }
}
