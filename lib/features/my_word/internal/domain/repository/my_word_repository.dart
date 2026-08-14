import 'package:my_dic/core/shared/utils/result.dart';
import 'delete_my_word_record.dart';
import 'my_word_page_query.dart';
import 'register_my_word_record.dart';
import 'update_my_word_record.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';

abstract interface class IMyWordRepository {
  // normal methods
  Future<Result<MyWord>> getById(String id, {required String accountId});
  Future<Result<List<MyWord>>> getFilteredByPage(MyWordPageQuery input,
      {required String accountId}); //TODO: 使用状況を確認する
  Future<Result<List<String>>> getIdsFilteredByPage(MyWordPageQuery input,
      {required String accountId});

  Future<Result<String>> registerWord(RegisterMyWordInputData input);
  Future<Result<void>> updateWord(UpdateMyWordInputData input);
  Future<Result<void>> deleteWord(DeleteMyWordInputData input);

  Stream<MyWord> watchMyWord(String id, {required String accountId});
}
