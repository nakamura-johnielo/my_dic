import 'package:flutter/material.dart';
import 'package:my_dic/features/search/application/query/search_conjugation_match_key.dart';
import 'package:my_dic/features/search/presentation/ui_model/search_conjugation_labels.dart';

class ConjugacionSearchCard extends StatelessWidget {
  const ConjugacionSearchCard(
      {super.key,
      required this.word,
      required this.query,
      required this.conjugacions,
      this.onTap});

  final String word;
  final String query;
  final Map<SearchConjugationMatchKey, String> conjugacions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    conjugacions.forEach((key, value) {
      if (value.isNotEmpty) {}
    });

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
          child: Row(children: [
            Text(
              word,
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, //color: wordColor
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(width: 15),
            Expanded(
              child: ConjSections(
                conjugacions: conjugacions,
                query: query,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class ConjSections extends StatelessWidget {
  const ConjSections(
      {super.key, required this.conjugacions, required this.query});
  final Map<SearchConjugationMatchKey, String> conjugacions;
  final String query;

  @override
  Widget build(BuildContext context) {
    final conjMiniSections = conjugacions.entries
        .where((entry) => entry.value.isNotEmpty) // 空でないものだけをフィルタリング
        .map((entry) => ConjMiniSection(
            moodTenseSubject: entry.key,
            conjugacion: entry.value)) // Textウィジェットを作成
        .toList();
    conjMiniSections.sort((a, b) =>
        a.conjugacion == query ? -1 : (b.conjugacion == query ? 1 : 0));
    return ClipRect(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // スクロールさせない（見切るだけ）
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: conjMiniSections,
        ),
      ),
    );
  }
}

class ConjMiniSection extends StatelessWidget {
  const ConjMiniSection(
      {super.key, required this.moodTenseSubject, required this.conjugacion});
  final SearchConjugationMatchKey moodTenseSubject;
  final String conjugacion;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurfaceVariant;
    String title =
        "${moodTenseSubject.moodTense.shortLabel}${moodTenseSubject.subject.name}:";
    if (moodTenseSubject.moodTense == SearchMoodTense.participlePast ||
        moodTenseSubject.moodTense == SearchMoodTense.participlePresent) {
      title = "${moodTenseSubject.moodTense.shortLabel}:";
    }

    return Row(spacing: 3, children: [
      Text(
        title,
        style: TextStyle(fontSize: 12, color: color),
        textAlign: TextAlign.left,
      ),
      Text(
        conjugacion,
        style: TextStyle(fontSize: 12, color: color),
        textAlign: TextAlign.left,
      )
    ]);
  }
}
