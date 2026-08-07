import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_local_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart';

import 'guest_data_summary.dart';

/// Reports whether any local row still sits under the guest scope, across
/// every dataset that supports real per-account scoping.
class DetectGuestDataUseCase {
  DetectGuestDataUseCase({
    required ILocalWordStatusDataSource espJpnWordStatus,
    required ILocalJpnEspWordStatusDataSource jpnEspWordStatus,
    required IMyWordLocalDataSource myWord,
    required IMyWordStatusLocalDataSource myWordStatus,
  })  : _espJpnWordStatus = espJpnWordStatus,
        _jpnEspWordStatus = jpnEspWordStatus,
        _myWord = myWord,
        _myWordStatus = myWordStatus;

  final ILocalWordStatusDataSource _espJpnWordStatus;
  final ILocalJpnEspWordStatusDataSource _jpnEspWordStatus;
  final IMyWordLocalDataSource _myWord;
  final IMyWordStatusLocalDataSource _myWordStatus;

  Future<GuestDataSummary> execute() async {
    final espJpn = await _espJpnWordStatus.getWordStatusAfter(
        MyDateTime.sentinel, guestAccountScope);
    final jpnEsp = await _jpnEspWordStatus.getWordStatusAfter(
        MyDateTime.sentinel, guestAccountScope);
    final myWords = await _myWord.getAllByAccountId(guestAccountScope);
    final myWordStatuses =
        await _myWordStatus.getAllByAccountId(guestAccountScope);

    return GuestDataSummary(
      espJpnWordStatusCount: espJpn.length,
      jpnEspWordStatusCount: jpnEsp.length,
      myWordCount: myWords.length,
      myWordStatusCount: myWordStatuses.length,
    );
  }
}
