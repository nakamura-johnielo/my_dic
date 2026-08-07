import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_dic/core/shared/enums/conjugacion/enum_mood_tense_subject.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/features/word_status/domain/dictionary_direction.dart';
import 'package:my_dic/features/word_status/presentation/status_button.dart';
import 'package:my_dic/features/search/presentation/components/card/reverse_curve.dart';

class CardView extends StatelessWidget {
  final int wordId;
  final void Function()? onTap;
  final void Function()? goToQuiz;
  final int? starCount;
  final String word;
  final String meaning;
  final int? ranking;
  final bool isBookmarked;
  final bool isLearned;
  final double quizBtnMargin;
  final Color? bgColor;

  final double mainRadius;
  final double designRadius;

  final bool rankingON;
  final Color? disableColor;

  final String query;
  final Map<MoodTenseSubject, String>? conjugacions;

  const CardView({
    super.key,
    required this.wordId,
    this.starCount,
    required this.word,
    required this.meaning,
    this.ranking,
    required this.isBookmarked,
    required this.isLearned,
    this.quizBtnMargin = 5.0,
    this.bgColor,
    this.mainRadius = 16,
    this.designRadius = 4,
    this.rankingON = true,
    this.onTap,
    this.disableColor,
    required this.query,
    this.conjugacions,
    this.goToQuiz,
  });

  final double ml = 16;
  final double mt = 12;
  final double mr = 16;
  final double mb = 6;

  static const double headWordFontSize = 18;
  final double meaningFontSize = 15;
  final double quizBtnFontSize = 13;
  final double rankingFontSize = 14;
  final double conjMetaFontSize = 13;
  final double conjFontSize = 15;

  final double rankingIconSize = 17;
  final double quizIconSize = 17;

  @override
  Widget build(BuildContext context) {
    final hasQuiz = goToQuiz != null;
    final backgroundColor =
        bgColor ?? Theme.of(context).colorScheme.surfaceContainer;
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final rankingColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final inactiveColor = disableColor ??
        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 0,
        children: [
          // upper part
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              //left==============================================

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusGeometry.directional(
                      topStart: Radius.circular(mainRadius),
                      topEnd: Radius.circular(mainRadius),
                      bottomStart: Radius.circular(0),
                      bottomEnd: Radius.circular(0),
                    ),
                    color:
                        backgroundColor, // Theme.of(context).colorScheme.primary,

                    //下段との接続部分に隙間ができるため、下段と同色のボーダーを入れて隙間を埋める
                    // border: Border(
                    //     bottom: BorderSide(color: backgroundColor, width: 4))
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(ml, mt, mr, mb),
                    child: Row(
                      children: [
                        Text(
                          word,
                          style: TextStyle(
                              fontSize: headWordFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                            child: Container(
                          width: double.infinity,
                        )),

                        //====status button=================
                        SizedBox(
                          width: 40,
                          height: 10,
                          child: OverflowBox(
                              alignment: Alignment.centerRight,
                              maxWidth: double.infinity,
                              maxHeight: double.infinity,
                              child: DictionaryStatusButtons(
                                wordId: wordId,
                                direction: DictionaryDirection.espJpn,
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              //notch
              SizedBox(
                width: quizBtnMargin,
                height: quizBtnMargin,
                child: OverflowBox(
                  alignment: Alignment.bottomLeft,
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: NotchCornerWidget(
                    color: backgroundColor,
                    //notchOffset: const Offset(2, -1), // 微調整
                    //notchRadius: 16.0,
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
              //quiz button section=====================
              Column(
                children: [
                  //button
                  GestureDetector(
                    onTap: goToQuiz,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusGeometry.directional(
                          topStart: Radius.circular(mainRadius),
                          topEnd: Radius.circular(mainRadius),
                          bottomStart: Radius.circular(mainRadius),
                          bottomEnd: Radius.circular(designRadius),
                        ),
                        color:
                            backgroundColor, // Theme.of(context).colorScheme.primary,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: ((mt + mb - quizBtnMargin) / 2)),
                        child: Row(
                          children: [
                            //見出し語と高さ揃えるためにテキスト挟む
                            const Text("a",
                                style: TextStyle(
                                    fontSize: headWordFontSize,
                                    color: Colors.transparent)),

                            Text(
                              "Quiz",
                              style: TextStyle(
                                  color: hasQuiz ? null : inactiveColor,
                                  fontSize: quizBtnFontSize,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Icon(
                              Icons.launch_rounded,
                              size: quizIconSize,
                              color: hasQuiz ? rankingColor : inactiveColor,
                            ),

                            const Text("a",
                                style: TextStyle(
                                    fontSize: headWordFontSize,
                                    color: Colors.transparent)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //margin
                  SizedBox(
                    height: quizBtnMargin,
                  )
                ],
              ),
            ],
          ),

          // lower part
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.directional(
                topStart: Radius.circular(0),
                topEnd: Radius.circular(designRadius * 2),
                bottomStart: Radius.circular(mainRadius),
                bottomEnd: Radius.circular(mainRadius),
              ),
              color: backgroundColor, // Theme.of(context).colorScheme.primary,
              // border: Border.all(
              //     color: Theme.of(context).colorScheme.primary,
              //     width: 2)
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min, //
                  children: [
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              meaning,
                              style: TextStyle(
                                  fontSize: meaningFontSize,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        //=====ranking===================
                        if (rankingON)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: rankingIconSize,
                                color: rankingColor,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              ranking != null
                                  ? Text(ranking!.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: rankingFontSize,
                                          color: rankingColor))
                                  : SizedBox(
                                      width: 9,
                                      height: 1.6,
                                      child: Container(
                                        color: rankingColor,
                                      )),
                            ],
                          ),
                      ],
                    ),
                    conjugacions != null
                        ? ConjSections(
                            conjugacions: conjugacions!,
                            query: query,
                            conjFontSize: conjFontSize,
                            metaFontSize: conjMetaFontSize,
                          )
                        : SizedBox.shrink(),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}

//===============conj=====================================

class ConjSections extends StatelessWidget {
  const ConjSections(
      {super.key,
      required this.conjugacions,
      required this.query,
      this.metaFontSize,
      this.conjFontSize,
      this.metaColor,
      this.conjColor});
  final Map<MoodTenseSubject, String> conjugacions;
  final String query;

  final double? metaFontSize;
  final double? conjFontSize;
  final Color? metaColor;
  final Color? conjColor;

  @override
  Widget build(BuildContext context) {
    final conjMiniSections = conjugacions.entries
        .where((entry) => entry.value.isNotEmpty) // 空でないものだけをフィルタリング
        .map((entry) => ConjMiniSection(
            metaFontSize: metaFontSize,
            conjFontSize: conjFontSize,
            metaColor: metaColor,
            conjColor: conjColor,
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
      {super.key,
      required this.moodTenseSubject,
      required this.conjugacion,
      this.metaFontSize,
      this.conjFontSize,
      this.metaColor,
      this.conjColor});
  final MoodTenseSubject moodTenseSubject;
  final String conjugacion;
  final double? metaFontSize;
  final double? conjFontSize;
  final Color? metaColor;
  final Color? conjColor;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurfaceVariant;

    String title =
        "${moodTenseSubject.moodTense.shorten}${moodTenseSubject.subject.name}:";

    if (moodTenseSubject.moodTense == MoodTense.participlePast ||
        moodTenseSubject.moodTense == MoodTense.participlePresent) {
      title = "${moodTenseSubject.moodTense.shorten}:";
    }

    return Row(spacing: 3, children: [
      Text(
        title,
        style: TextStyle(fontSize: metaFontSize ?? 12, color: metaColor),
        textAlign: TextAlign.left,
      ),
      Text(
        conjugacion,
        style: TextStyle(fontSize: conjFontSize ?? 12, color: conjColor),
        textAlign: TextAlign.left,
      )
    ]);
  }
}
