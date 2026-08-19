import 'package:my_dic/features/my_word/port/my_word.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

import 'guest_data_summary.dart';

/// 実際のアカウント別スコープをサポートする全データセットを対象に、いずれかのローカル行が
/// まだゲストスコープに残っているかを報告します。
class DetectGuestDataUseCase {
  DetectGuestDataUseCase({
    required WordStatusGuestMigrationPort wordStatus,
    required MyWordGuestMigrationPort myWord,
    required UserProfileGuestMigrationPort userProfile,
  })  : _wordStatusAdapter = wordStatus,
        _myWordAdapter = myWord,
        _userProfileAdapter = userProfile;

  final WordStatusGuestMigrationPort _wordStatusAdapter;
  final MyWordGuestMigrationPort _myWordAdapter;
  final UserProfileGuestMigrationPort _userProfileAdapter;

  Future<GuestDataSummary> execute() async {
    final wordStatus = await _wordStatusAdapter.countGuestRows();
    final myWord = await _myWordAdapter.countGuestRows();
    final userProfile = await _userProfileAdapter.hasGuestProfile();

    return GuestDataSummary(
      espJpnWordStatusCount: wordStatus.espJpn,
      jpnEspWordStatusCount: wordStatus.jpnEsp,
      myWordCount: myWord.words,
      myWordStatusCount: myWord.statuses,
      userProfileCount: userProfile ? 1 : 0,
    );
  }
}
