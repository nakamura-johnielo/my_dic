import 'package:my_dic/features/my_word/internal/infrastructure/mapper/my_word_result_mapper.dart';
import 'package:my_dic/features/my_word/internal/application/query/i_my_word_item_query_repository.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/delete_my_word/delete_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/update/i_update_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/update/update_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/port/command.dart';
import 'package:my_dic/features/my_word/port/query.dart';
import 'package:my_dic/features/my_word/port/result.dart';

/// レガシーアプリケーションのユースケースに裏打ちされた、パブリック向けのポート。
///
/// レガシーの入力データ型およびユースケース型は、意図的に内部用として残されています。
/// このアダプタは、利用者が本機能のコマンド／クエリ契約へ移行する間、それらの互換性の境界となります。
final class MyWordApplicationAdapter
    implements MyWordCommandPort, MyWordStatusCommandPort, MyWordReaderPort {
  const MyWordApplicationAdapter({
    required IRegisterMyWordUseCase registerUseCase,
    required IUpdateMyWordUseCase updateUseCase,
    required IDeleteMyWordUseCase deleteUseCase,
    required IUpdateMyWordStatusUseCase updateStatusUseCase,
    required ILoadMyWordUseCase loadUseCase,
    required IMyWordItemQueryRepository itemQueryRepository,
  })  : _registerUseCase = registerUseCase,
        _updateUseCase = updateUseCase,
        _deleteUseCase = deleteUseCase,
        _updateStatusUseCase = updateStatusUseCase,
        _loadUseCase = loadUseCase,
        _itemQueryRepository = itemQueryRepository;

  final IRegisterMyWordUseCase _registerUseCase;
  final IUpdateMyWordUseCase _updateUseCase;
  final IDeleteMyWordUseCase _deleteUseCase;
  final IUpdateMyWordStatusUseCase _updateStatusUseCase;
  final ILoadMyWordUseCase _loadUseCase;
  final IMyWordItemQueryRepository _itemQueryRepository;

  @override
  Future<Result<String>> register(RegisterMyWordCommand command) =>
      _registerUseCase.execute(RegisterMyWordInputData(
        command.headword,
        command.description,
        command.accountScope,
      ));

  @override
  Future<Result<void>> update(UpdateMyWordCommand command) =>
      _updateUseCase.execute(UpdateMyWordInputData(
        command.myWordId,
        command.headword,
        command.description,
        command.accountScope,
      ));

  @override
  Future<Result<void>> delete(DeleteMyWordCommand command) =>
      _deleteUseCase.execute(
        DeleteMyWordInputData(command.myWordId, command.accountScope),
      );

  @override
  Future<Result<void>> updateStatus(UpdateMyWordStatusCommand command) =>
      _updateStatusUseCase.execute(UpdateMyWordStatusInputData(
        command.myWordId,
        command.isLearned,
        command.isBookmarked,
        command.hasNote,
        command.accountScope,
      ));

  @override
  Future<Result<List<String>>> loadIds(LoadMyWordsQuery query) =>
      _loadUseCase.executeIds(
        LoadMyWordInputData(query.size, query.page, query.accountScope),
      );

  @override
  Stream<MyWordItem?> watchItem(WatchMyWordItemQuery query) =>
      _itemQueryRepository
          .watchItem(query.myWordId, accountId: query.accountScope)
          .map((projection) =>
              projection == null ? null : MyWordResultMapper.item(projection));
}
