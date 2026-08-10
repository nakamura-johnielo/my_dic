import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/port/repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

final class WatchWordStatus {
  WatchWordStatus(this._repository);

  final WordStatusRepository _repository;

  Stream<WordStatus> execute(CatalogWordRef word, {required String accountScope}) =>
      _repository.watch(word, accountId: accountScope);
}
