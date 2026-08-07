import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/components/button/my_icon_button.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/shared/enums/my_icons.dart';
import 'package:my_dic/core/shared/enums/ui/word_card_view_click_listener.dart';
import 'package:my_dic/features/my_word/di/view_model_di.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_event.dart';

const Map<String, IconData> _bookmarkIcon = {
  "true": Icons.bookmark_rounded,
  "false": Icons.bookmark_border_rounded,
  "added": Icons.bookmark_added_rounded
};
const Map<String, IconData> _learnedIcon = {
  "true": Icons.check_circle_rounded,
  "false": Icons.check_circle_outline_rounded
};

class MyWordCardModal extends ConsumerStatefulWidget {
  const MyWordCardModal(
      {super.key,
      required this.myWord,
      required this.index,
      this.onTap,
      this.onChanged,
      this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      required this.clickListeners});

  final MyWordUiState myWord;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onChanged;
  final EdgeInsetsGeometry? margin;
  final Map<WordCardViewButton, VoidCallback> clickListeners;

  @override
  ConsumerState<MyWordCardModal> createState() => _MyWordCardModalState();
}

class _MyWordCardModalState extends ConsumerState<MyWordCardModal> {
  late String myHeaderWord;
  late String myDescription;
  late final VoidCallback? onTap;
  late final EdgeInsetsGeometry? margin;

  late final TextEditingController headwordTextFieldController;
  late final TextEditingController descriptionTextFieldController;

  bool _isOnEdit = false;
  late final ProviderSubscription<MyWordCommandState> _commandSubscription;

  @override
  void initState() {
    super.initState();
    myHeaderWord = widget.myWord.word;
    myDescription = widget.myWord.contents;

    onTap = widget.onTap;
    margin = widget.margin;
    headwordTextFieldController = TextEditingController();
    descriptionTextFieldController = TextEditingController();
    _commandSubscription = ref.listenManual(
      myWordCommandProvider(widget.myWord.wordId),
      (_, next) => _handleEffect(next),
    );
  }

  void inicializeOnEdit() {
    headwordTextFieldController.text = myHeaderWord;
    descriptionTextFieldController.text = myDescription;
    setState(() {
      _isOnEdit = !_isOnEdit;
    });
  }

  @override
  void dispose() {
    _commandSubscription.close();
    // コントローラーを解放
    headwordTextFieldController.dispose();
    descriptionTextFieldController.dispose();
    super.dispose();
  }

  void _handleEffect(MyWordCommandState next) {
    final envelope = next.pendingEffect;
    if (envelope == null || !mounted) return;
    final command =
        ref.read(myWordCommandProvider(widget.myWord.wordId).notifier);
    if (envelope.effect is UiCloseDialogEffect &&
        next.command.operation == 'delete') {
      widget.onChanged?.call();
      Navigator.of(context).pop();
    } else if (envelope.effect is UiNoticeEffect) {
      if (next.command.operation == 'update' && next.command.isSucceeded) {
        setState(() {
          _isOnEdit = false;
          myDescription = descriptionTextFieldController.text;
          myHeaderWord = headwordTextFieldController.text;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((envelope.effect as UiNoticeEffect).message)),
      );
    }
    command.consumeEffect(envelope.id);
  }

  @override
  Widget build(BuildContext context) {
    final commandState = ref.watch(myWordCommandProvider(widget.myWord.wordId));

    Color descriptionColor = Theme.of(context).colorScheme.onSurfaceVariant;
    Color headwordColor = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: margin,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        spacing: 0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //word.
                          if (!_isOnEdit)
                            Text(
                              myHeaderWord,
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  color: headwordColor),
                              textAlign: TextAlign.left,
                            ),
                          if (_isOnEdit)
                            TextField(
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w600),
                              autofocus: false,
                              controller: headwordTextFieldController,
                              decoration: InputDecoration(
                                labelText: '見出し語',
                                hintText: '単語・フレーズを入力',
                              ),
                            ),
                          SizedBox(
                            height: 30,
                          ),

                          //description
                          if (!_isOnEdit)
                            Container(
                              //width: 160,
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                myDescription,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: descriptionColor),
                                textAlign: TextAlign.left,
                              ),
                            ),

                          if (_isOnEdit)
                            TextField(
                              minLines: 3,
                              maxLines: null,
                              autofocus: true,
                              controller: descriptionTextFieldController,
                              decoration: InputDecoration(
                                hintText: 'なにかしらの意味',
                                labelText: 'メモ',
                                border: OutlineInputBorder(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // SizedBox(width: 15),
                    //TODO 一旦status更新ナシ
                    /* ButtonSection(
                        //
                        clickListeners: widget.clickListeners,
                        isFlags: {
                          WordCardViewButton.learned: widget.myWord.isLearned,
                          WordCardViewButton.bookmark:
                              widget.myWord.isBookmarked
                        },
                        iconSizes: {
                          WordCardViewButton.learned: 22,
                          WordCardViewButton.bookmark: 24
                        }), */
                  ]),
              SizedBox(
                height: 30,
              ),
              if (!_isOnEdit)
                //edit
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 30,
                  children: [
                    MyIconButton(
                      iconSize: 24,
                      defaultIcon: MyIcons.edit.icon,
                      hoveredIcon: MyIcons.edit.icon,
                      hoveredIconColor:
                          const Color.fromARGB(255, 119, 119, 119),
                      onTap: () {
                        inicializeOnEdit();
                      },
                    ),
                    MyIconButton(
                      iconSize: 24,
                      defaultIcon: MyIcons.delete.icon,
                      hoveredIcon: MyIcons.delete.icon,
                      defaultIconColor: const Color.fromARGB(255, 217, 60, 60),
                      hoveredIconColor: const Color.fromARGB(255, 255, 0, 106),
                      onTap: commandState.command.isSubmitting
                          ? null
                          : () => ref
                              .read(myWordCommandProvider(widget.myWord.wordId)
                                  .notifier)
                              .deleteWord(),
                    ),
                  ],
                ),
              if (_isOnEdit)
                Row(
                  children: [
                    SizedBox(width: 20),
                    Expanded(
                        child: FilledButton(
                            onPressed: commandState.command.isSubmitting
                                ? null
                                : () => ref
                                    .read(myWordCommandProvider(
                                            widget.myWord.wordId)
                                        .notifier)
                                    .updateWord(
                                      headword:
                                          headwordTextFieldController.text,
                                      description:
                                          descriptionTextFieldController.text,
                                    ),
                            child: commandState.command.isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  )
                                : const Text("save"))),
                    SizedBox(
                      width: 33,
                    ),
                    Expanded(
                      child: TextButton(
                          onPressed: () {
                            inicializeOnEdit();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // 背景色
                            foregroundColor:
                                const Color.fromARGB(255, 223, 58, 58), // テキスト色
                          ),
                          child: Text("cancel")),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//スマホ用
class MyWordCardModal4 extends StatelessWidget {
  //
  const MyWordCardModal4(
      {super.key,
      required this.myWord,
      this.onTap,
      this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      required this.clickListeners});

  final MyWord myWord;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Map<WordCardViewButton, VoidCallback> clickListeners;

  static const Color hinshiColor = Color.fromARGB(255, 40, 40, 40);
  static const Color wordColor = Colors.black;
  static const Color headwordColor = Colors.black;
  static const Color meaningColor = Colors.black;

  static const Map<String, IconData> bookmarkIcon = {
    "true": Icons.bookmark_rounded,
    "false": Icons.bookmark_border_rounded,
    "added": Icons.bookmark_added_rounded
  };
  static const Map<String, IconData> learnedIcon = {
    "true": Icons.check_circle_rounded,
    "false": Icons.check_circle_outline_rounded
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: margin,
        color: const Color.fromARGB(255, 234, 234, 234),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    spacing: 0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //word.
                      Text(
                        myWord.word,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: headwordColor),
                        textAlign: TextAlign.left,
                      ),

                      //description
                      Container(
                        //width: 160,
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          myWord.contents,
                          style: TextStyle(fontSize: 15, color: wordColor),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      //edit
                      MyIconButton(
                        iconSize: 24,
                        defaultIcon: MyIcons.edit.icon,
                        hoveredIcon: MyIcons.edit.icon,
                        hoveredIconColor:
                            const Color.fromARGB(255, 119, 119, 119),
                        onTap: () {
                          clickListeners[WordCardViewButton.learned]!();
                        },
                      ),
                    ],
                  ),
                ),

                // SizedBox(width: 15),
                ButtonSection(
                    //
                    clickListeners: clickListeners,
                    isFlags: {
                      WordCardViewButton.learned: myWord.isLearned,
                      WordCardViewButton.bookmark: myWord.isBookmarked
                    },
                    iconSizes: {
                      WordCardViewButton.learned: 22,
                      WordCardViewButton.bookmark: 24
                    }),
              ]),
        ),
      ),
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({
    super.key,
    required this.clickListeners,
    required this.isFlags,
    required this.iconSizes,
  });
  final Map<WordCardViewButton, VoidCallback> clickListeners;
  final Map<WordCardViewButton, bool> isFlags;
  final Map<WordCardViewButton, double> iconSizes;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: Row(
          spacing: 3,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyIconButton(
              iconSize: iconSizes[WordCardViewButton.learned]!,
              defaultIcon: isFlags[WordCardViewButton.learned]!
                  ? _learnedIcon["true"] ?? Icons.error
                  : _learnedIcon["false"] ?? Icons.error,
              hoveredIcon: isFlags[WordCardViewButton.learned]!
                  ? _learnedIcon["true"] ?? Icons.error
                  : _learnedIcon["false"] ?? Icons.error,
              hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
              onTap: () {
                clickListeners[WordCardViewButton.learned]!();
              },
            ),
            MyIconButton(
              iconSize: iconSizes[WordCardViewButton.bookmark]!,
              defaultIcon: isFlags[WordCardViewButton.bookmark]!
                  ? _bookmarkIcon["true"] ?? Icons.error
                  : _bookmarkIcon["false"] ?? Icons.error,
              hoveredIcon: isFlags[WordCardViewButton.bookmark]!
                  ? _bookmarkIcon["true"] ?? Icons.error
                  : _bookmarkIcon["false"] ?? Icons.error,
              hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
              onTap: () {
                clickListeners[WordCardViewButton.bookmark]!();
              },
            ),
          ],
        ));
  }
}
