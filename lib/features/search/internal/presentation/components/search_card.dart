import 'package:flutter/material.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

class SearchCard extends StatelessWidget {
  const SearchCard(
      {super.key, required this.word, required this.partOfSpeech, this.onTap});

  final String word;
  final List<CatalogPartOfSpeech> partOfSpeech;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color hinshiColor = Theme.of(context).colorScheme.onSurfaceVariant;
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
                SizedBox(width: 15),
                Text(
                  partOfSpeech.map((p) => p.wireValue).join(','),
                  style: TextStyle(fontSize: 12, color: hinshiColor),
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
