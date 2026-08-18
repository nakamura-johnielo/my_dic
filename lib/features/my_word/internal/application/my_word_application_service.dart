import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/application/mapper/my_word_result_mapper.dart';
import 'package:my_dic/features/my_word/internal/application/query/my_word_item_query.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_status_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/delete_my_word_record.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_page_query.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/register_my_word_record.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/update_my_word_record.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/update_my_word_status_record.dart';
import 'package:my_dic/features/my_word/port/command.dart';
import 'package:my_dic/features/my_word/port/query.dart';
import 'package:my_dic/features/my_word/port/result.dart';

/// Coordinates the MyWord application contract over owner-internal
/// persistence seams.
final class MyWordApplicationService
    implements MyWordCommandPort, MyWordStatusCommandPort, MyWordQueryPort {
  const MyWordApplicationService({
    required IMyWordRepository wordRepository,
    required IMyWordStatusRepository statusRepository,
    required MyWordItemQuery itemQuery,
  })  : _wordRepository = wordRepository,
        _statusRepository = statusRepository,
        _itemQuery = itemQuery;

  final IMyWordRepository _wordRepository;
  final IMyWordStatusRepository _statusRepository;
  final MyWordItemQuery _itemQuery;

  @override
  Future<Result<String>> register(RegisterMyWordCommand command) async {
    final validationError = _validateEditableContents(
      command.headword,
      command.description,
    );
    if (validationError != null) return Result.failure(validationError);

    return _wordRepository.registerWord(RegisterMyWordInputData(
      command.headword.trim(),
      command.description.trim(),
      DateTime.now().toUtc(),
      _accountId(command.accountScope),
    ));
  }

  @override
  Future<Result<void>> update(UpdateMyWordCommand command) async {
    final validationError = _validateEditableContents(
      command.headword,
      command.description,
    );
    if (validationError != null) return Result.failure(validationError);

    return _wordRepository.updateWord(UpdateMyWordInputData(
      command.myWordId,
      command.headword.trim(),
      command.description.trim(),
      DateTime.now().toUtc(),
      _accountId(command.accountScope),
    ));
  }

  @override
  Future<Result<void>> delete(DeleteMyWordCommand command) =>
      _wordRepository.deleteWord(DeleteMyWordInputData(
        command.myWordId,
        MyDateTime.getNowUTCDateHour().toIso8601String(),
        _accountId(command.accountScope),
      ));

  @override
  Future<Result<void>> updateStatus(UpdateMyWordStatusCommand command) =>
      _statusRepository.updateStatus(UpdateMyWordStatusInputData(
        command.myWordId,
        command.isLearned,
        command.isBookmarked,
        command.hasNote,
        DateTime.now().toUtc(),
        _accountId(command.accountScope),
      ));

  @override
  Future<Result<List<String>>> loadIds(LoadMyWordsQuery query) {
    final validationError = _validatePage(query);
    if (validationError != null) {
      return Future.value(Result.failure(validationError));
    }

    return _wordRepository.getIdsFilteredByPage(
      MyWordPageQuery(query.size, query.page * query.size),
      accountId: query.accountScope,
    );
  }

  @override
  Stream<MyWordItem?> watchItem(WatchMyWordItemQuery query) => _itemQuery
      .watchItem(query.myWordId, accountId: query.accountScope)
      .map((projection) =>
          projection == null ? null : MyWordResultMapper.item(projection));

  String? _accountId(String accountScope) =>
      accountScope == guestAccountScope ? null : accountScope;

  ValidationError? _validateEditableContents(
    String headword,
    String description,
  ) {
    final errors = <String, List<String>>{};
    if (headword.trim().isEmpty) {
      errors['headword'] = ['単語を入力してください'];
    } else if (headword.trim().length > 100) {
      errors['headword'] = ['単語は100文字以内で入力してください'];
    }
    if (description.trim().length > 1000) {
      errors['description'] = ['説明は1000文字以内で入力してください'];
    }
    if (errors.isEmpty) return null;
    return ValidationError(
      message: '入力内容に誤りがあります',
      fieldErrors: errors,
    );
  }

  ValidationError? _validatePage(LoadMyWordsQuery query) {
    if (query.page < 0) {
      return ValidationError(message: 'ページ番号は0以上である必要があります');
    }
    if (query.size <= 0) {
      return ValidationError(message: 'ページサイズは1以上である必要があります');
    }
    return null;
  }
}
