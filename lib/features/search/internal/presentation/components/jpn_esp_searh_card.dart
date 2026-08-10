import 'package:flutter/material.dart';

class JpnEspSearchCard extends StatelessWidget {
  const JpnEspSearchCard({super.key, required this.word, this.onTap});

  final String word;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                width: 1,
                color: const Color.fromARGB(255, 157, 157, 157)), // 下ボーダー
          ),
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            children: [
              Row(children: [
                Text(
                  word,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
