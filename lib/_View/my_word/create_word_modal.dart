import 'dart:developer';

import 'package:flutter/material.dart';

class CreateWordModal extends StatefulWidget {
  const CreateWordModal({super.key});

  @override
  State<CreateWordModal> createState() => _CreateWordModalState();
}

class _CreateWordModalState extends State<CreateWordModal> {
  final headwordTextFieldController = TextEditingController();
  final descriptionTextFieldController = TextEditingController();
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
                              log(headwordTextFieldController.text);
                              log(descriptionTextFieldController.text);
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
