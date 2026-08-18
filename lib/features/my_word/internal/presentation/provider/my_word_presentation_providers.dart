import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/my_word/port/query.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_event.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_command.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_status_command.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_view_model.dart';

typedef MyWordPresentationKey = ({SessionScopeKey scope, MyWordPorts ports});
typedef MyWordItemPresentationKey = ({
  SessionScopeKey scope,
  MyWordPorts ports,
  String wordId
});

final myWordFragmentViewModelProvider = StateNotifierProvider.autoDispose
    .family<MyWordFragmentViewModel, MyWordFragmentState,
            MyWordPresentationKey>(
        (ref, key) => MyWordFragmentViewModel(
            key.ports.reader, key.ports.commands, key.scope));

final myWordItemUiModelProvider = StreamProvider.autoDispose
    .family<MyWordItemUiModel?, MyWordItemPresentationKey>((ref, key) => key
        .ports.reader
        .watchItem(WatchMyWordItemQuery(
            myWordId: key.wordId, accountScope: key.scope.accountScope))
        .map((item) => item == null ? null : MyWordItemUiModel.fromItem(item)));

final myWordStatusCommandProvider = StateNotifierProvider.autoDispose.family<
        MyWordStatusCommand,
        MyWordStatusCommandState,
        MyWordItemPresentationKey>(
    (ref, key) =>
        MyWordStatusCommand(key.wordId, key.ports.statusCommands, key.scope));

final myWordCommandProvider = StateNotifierProvider.autoDispose
    .family<MyWordCommand, MyWordCommandState, MyWordItemPresentationKey>(
        (ref, key) => MyWordCommand(key.wordId, key.ports.commands, key.scope));

final myWordRegistrationCommandProvider = StateNotifierProvider.autoDispose
    .family<MyWordRegistrationCommand, MyWordCommandState,
            MyWordPresentationKey>(
        (ref, key) => MyWordRegistrationCommand(key.ports.commands, key.scope));
