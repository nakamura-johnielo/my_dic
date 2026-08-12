import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/port/repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

final class WatchWordStatusInteractor {
  WatchWordStatusInteractor(this._repository);

  final IWordStatusRepository _repository;

  Stream<WordStatus> execute(CatalogWordRef word,
          {required String accountScope}) =>
      _repository.watch(word, accountId: accountScope);
}
