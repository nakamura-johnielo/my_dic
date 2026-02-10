import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_dic/core/shared/enums/conjugacion/enum_mood_tense_subject.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/status_buttons.dart';
import 'package:my_dic/features/search/presentation/components/card/reverse_curve.dart';

class CardView extends StatefulWidget {
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

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
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

  bool isMainHovering = false;
  bool isQuizHovering = false;

  void _onMainHover(bool hovering) {
    setState(() {
      isMainHovering = hovering;
    });
  }

  void _onQuizHover(bool hovering) {
    setState(() {
      isQuizHovering = hovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasQuiz = widget.goToQuiz != null;
    final backgroundColor =
        widget.bgColor ?? Theme.of(context).colorScheme.surfaceContainer;
    final Color hoverColor = Color.alphaBlend(
        Theme.of(context).colorScheme.primary.withOpacity(0.1),
        backgroundColor);
        final Color hoverQuizColor=Color.alphaBlend(
        Theme.of(context).colorScheme.primary.withOpacity(0.4),
        backgroundColor);
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final rankingColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final inactiveColor = widget.disableColor ??
        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5);

    return MouseRegion(
      onEnter: (_) => _onMainHover(true),
      onExit: (_) => _onMainHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
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
                        topStart: Radius.circular(widget.mainRadius),
                        topEnd: Radius.circular(widget.mainRadius),
                        bottomStart: Radius.circular(0),
                        bottomEnd: Radius.circular(0),
                      ),
                      color: isMainHovering
                          ? hoverColor
                          : backgroundColor, // Theme.of(context).colorScheme.primary,

                      //下段との接続部分に隙間ができるため、下段と同色のボーダーを入れて隙間を埋める
                      // border: Border(
                      //     bottom: BorderSide(color: backgroundColor, width: 4))
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(ml, mt, mr, mb),
                      child: Row(
                        children: [
                          Text(
                            widget.word,
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
                                child: StatusButtons(wordId: widget.wordId)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                //notch
                SizedBox(
                  width: widget.quizBtnMargin,
                  height: widget.quizBtnMargin,
                  child: OverflowBox(
                    alignment: Alignment.bottomLeft,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: NotchCornerWidget(
                      color: isMainHovering ? hoverColor : backgroundColor,
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
                    MouseRegion(
                      onEnter: (_) {
                        if (!hasQuiz) return;
                        _onMainHover(false);
                        _onQuizHover(true);
                      },
                      onExit: (_) {
                        if (!hasQuiz) return;
                        _onMainHover(true);
                        _onQuizHover(false);
                      },
                      child: GestureDetector(
                        onTap: widget.goToQuiz,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusGeometry.directional(
                              topStart: Radius.circular(widget.mainRadius),
                              topEnd: Radius.circular(widget.mainRadius),
                              bottomStart: Radius.circular(widget.mainRadius),
                              bottomEnd: Radius.circular(widget.designRadius),
                            ),
                            color: isQuizHovering
                                ? hoverQuizColor
                                : backgroundColor, // Theme.of(context).colorScheme.primary,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical:
                                    ((mt + mb - widget.quizBtnMargin) / 2)),
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
                    ),

                    //margin
                    SizedBox(
                      height: widget.quizBtnMargin,
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
                  topEnd: Radius.circular(widget.designRadius * 2),
                  bottomStart: Radius.circular(widget.mainRadius),
                  bottomEnd: Radius.circular(widget.mainRadius),
                ),
                color: isMainHovering
                    ? hoverColor
                    : backgroundColor, // Theme.of(context).colorScheme.primary,
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
                        spacing: 20,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                widget.meaning,
                                style: TextStyle(
                                    fontSize: meaningFontSize,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          //=====ranking===================
                          if (widget.rankingON)
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
                                widget.ranking != null
                                    ? Text(widget.ranking!.toString(),
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
                      widget.conjugacions != null
                          ? ConjSections(
                              conjugacions: widget.conjugacions!,
                              query: widget.query,
                              conjFontSize: conjFontSize,
                              metaFontSize: conjMetaFontSize,
                            )
                          : SizedBox.shrink(),
                    ]),
              ),
            ),
          ],
        ),
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
          queryNullable: query,
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
      this.conjColor, this.queryNullable});
  final MoodTenseSubject moodTenseSubject;
  final String conjugacion;
  final double? metaFontSize;
  final double? conjFontSize;
  final Color? metaColor;
  final Color? conjColor;
  final String? queryNullable;


  Widget _highlightMatch(BuildContext context, String conj) {
    
    if (queryNullable?.isEmpty??true) {
      return Text(conj,
          style: TextStyle(
            fontSize: conjFontSize??12,//TODO fontsize 
           // color: widget.conjColor
          ),
          textAlign: TextAlign.left);

    }final query=queryNullable!;

    final lowerText = conj.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);
    if (start < 0) {
      return Text(conj,
          style: TextStyle(
             fontSize: conjFontSize??12,//TODO fontsize 
          ),
          textAlign: TextAlign.left);
    }
    final end = start + query.length;
    //完全一致か部分一致か
    Color highlightColor = conj.length == query.length
        ? Theme.of(context).colorScheme.primary //Colors.indigo[200]!
        : Theme.of(context).colorScheme.primary.withOpacity(0.5);
    Color? highlightTextColor = conj.length == query.length
        ? Theme.of(context).colorScheme.onPrimary //Colors.indigo[200]!
        : null;

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: conjFontSize ?? 12, //color: conjColor
        ),
        children: [
          TextSpan(text: conj.substring(0, start)),
          TextSpan(
            text: conj.substring(start, end),
            style: TextStyle(fontWeight: FontWeight.bold,
                backgroundColor: highlightColor, color: highlightTextColor),
          ),
          TextSpan(text: conj.substring(end)),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }


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
      _highlightMatch(context, conjugacion)
      
    ]);
  }
}

