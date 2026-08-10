import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/port/repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

final class FetchWordStatus {
  FetchWordStatus(this._repository);

  final WordStatusRepository _repository;

  Future<Result<WordStatus>> execute(
    CatalogWordRef word, {
    required String accountScope,
  }) async {
    final result = await _repository.get(word, accountId: accountScope);
    return result.map(
      (status) => status ?? WordStatus(
        word: word,
        isLearned: false,
        isBookmarked: false,
        hasNote: false,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      ),
    );
  }
}
