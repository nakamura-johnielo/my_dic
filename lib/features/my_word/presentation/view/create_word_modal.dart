import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/my_word/di/view_model_di.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_view_model.dart';
import 'package:my_dic/features/user/di/service.dart';

class WordRegistrationModal extends ConsumerStatefulWidget {
  const WordRegistrationModal({super.key, this.onRegistered});

  final VoidCallback? onRegistered;

  @override
  ConsumerState<WordRegistrationModal> createState() =>
      _WordRegistrationModalState();
}

class _WordRegistrationModalState extends ConsumerState<WordRegistrationModal> {
  final headwordTextFieldController = TextEditingController();
  final descriptionTextFieldController = TextEditingController();
  late final MyWordFragmentViewModel controller;

  @override
  void initState() {
    super.initState();
    //controller = widget._controller;
    controller = ref.read(myWordFragmentViewModelProvider.notifier);
  }

  @override
  void dispose() {
    headwordTextFieldController.dispose();
    descriptionTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final controller=ref.read(myWordControllerProvider);
    final Color bg = Theme.of(context).colorScheme.surfaceContainer;
    return FractionallySizedBox(
      heightFactor: 0.9,
      widthFactor: 0.8,
      child: Container(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        //margin: EdgeInsets.only(top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Word 登録',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* Text(
                      "見出し語:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ), */
                    TextField(
                      autofocus: true,
                      controller: headwordTextFieldController,
                      decoration: InputDecoration(
                        labelText: '見出し語',
                        hintText: '単語・フレーズを入力',
                      ),
                    ),

                    SizedBox(
                      height: 26,
                    ),
                    /* Text(
                      "メモ:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ), */
                    TextField(
                      minLines: 3,
                      maxLines: null,
                      controller: descriptionTextFieldController,
                      decoration: InputDecoration(
                        hintText: 'なにかしらの意味',
                        labelText: 'メモ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 56,
                    ),
                    // Flutter1.22以降のみ
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: FilledButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              elevation: 0,
                              // foregroundColor:
                              //     const Color.fromARGB(255, 255, 255, 255),
                              // backgroundColor:
                              //     const Color.fromARGB(255, 44, 110, 215),
                            ),
                            onPressed: () {
                              controller.registerWord(
                                userId: ref.read(authStoreNotifierProvider)?.accountId,
                                  headword: headwordTextFieldController.text,
                                  description:
                                      descriptionTextFieldController.text,
                                  onComplete: () {
                                    //descriptionTextFieldController.clear();
                                    //headwordTextFieldController.clear();
                                    //モーダル閉じる
                                    widget.onRegistered?.call();
                                    Navigator.of(context).pop();
                                    //showToast("registered successfully!");
                                  },
                                  onError: () {
                                    //showToast("なにかしらERROR");
                                  },
                                  onInvalid: () {
                                    log("invalid input");
                                    //showToast("入力してください");
                                  });
                            },
                            child: const Text('登録'),
                          ),
                        )),
                        SizedBox(width: 20),
                      ],
                    ),
                    /*  SizedBox(
                      height: 20,
                    ),
                 Center(
                      child: Text(
                        "error",
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ) */
                  ]),
            )
          ],
        ),
      ),
    );
  }
}

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT, // 表示時間: SHORT or LONG
    gravity: ToastGravity.BOTTOM, // 位置: BOTTOM, CENTER, TOP
    // backgroundColor: Color.fromARGB(131, 0, 0, 0), // 背景色
    // textColor: Colors.white, // テキスト色
    fontSize: 16.0, // フォントサイズ
  );
}

class CreateWordModal2 extends StatelessWidget {
  CreateWordModal2({super.key});

  final textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.98,
      widthFactor: 0.96,
      child: Container(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        //margin: EdgeInsets.only(top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Word 登録',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "見出し語:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    TextField(
                      autofocus: true,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: '単語・フレーズを入力',
                      ),
                    ),
                    SizedBox(
                      height: 56,
                    ),
                    // Flutter1.22以降のみ
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              elevation: 0,
                              foregroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              backgroundColor:
                                  const Color.fromARGB(255, 44, 110, 215),
                            ),
                            onPressed: () {
                              log(textEditingController.text);
                            },
                            child: const Text('登録'),
                          ),
                        )),
                        SizedBox(width: 20),
                      ],
                    )
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
