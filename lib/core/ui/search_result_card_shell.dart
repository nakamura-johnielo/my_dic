import 'package:flutter/material.dart';

/// 辞書検索結果のための、機能に依存しない視覚的なシェル。
///
/// 機能固有の状態、ステータス操作、補足結果コンテンツはスロット経由で提供し、
/// コアUIが機能に依存しないようにします。
class SearchResultCardShell extends StatefulWidget {
  const SearchResultCardShell({
    super.key,
    required this.word,
    required this.meaning,
    required this.status,
    this.onTap,
    this.onQuizTap,
    this.ranking,
    this.showRanking = true,
    this.query,
    this.supplementary,
    this.quizButtonMargin = 5,
    this.backgroundColor,
    this.mainRadius = 16,
    this.designRadius = 4,
    this.disabledColor,
  });

  final String word;
  final String meaning;
  final Widget status;
  final VoidCallback? onTap;
  final VoidCallback? onQuizTap;
  final int? ranking;
  final bool showRanking;
  final String? query;
  final Widget? supplementary;
  final double quizButtonMargin;
  final Color? backgroundColor;
  final double mainRadius;
  final double designRadius;
  final Color? disabledColor;

  @override
  State<SearchResultCardShell> createState() => _SearchResultCardShellState();
}

class _SearchResultCardShellState extends State<SearchResultCardShell> {
  bool _mainHovering = false;
  bool _quizHovering = false;

  void _setMainHovering(bool value) => setState(() => _mainHovering = value);
  void _setQuizHovering(bool value) => setState(() => _quizHovering = value);

  @override
  Widget build(BuildContext context) {
    final hasQuiz = widget.onQuizTap != null;
    final background = widget.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainer;
    final hover = Color.alphaBlend(
        Theme.of(context).colorScheme.primary.withValues(alpha: .1),
        background);
    final quizHover = Color.alphaBlend(
        Theme.of(context).colorScheme.primary.withValues(alpha: .4),
        background);
    final rankingColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final disabled = widget.disabledColor ?? rankingColor.withValues(alpha: .5);
    final mainColor = _mainHovering ? hover : background;

    return MouseRegion(
      onEnter: (_) => _setMainHovering(true),
      onExit: (_) => _setMainHovering(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(widget.mainRadius)),
                color: mainColor,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(children: [
                  Text(widget.word,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Expanded(child: SizedBox()),
                  SizedBox(
                    width: 72,
                    height: 28,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: widget.status,
                    ),
                  ),
                ]),
              ),
            )),
            SizedBox(
              width: widget.quizButtonMargin,
              height: widget.quizButtonMargin,
              child: OverflowBox(
                alignment: Alignment.bottomLeft,
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: _NotchCorner(color: mainColor),
              ),
            ),
            Column(children: [
              MouseRegion(
                onEnter: (_) {
                  if (hasQuiz) {
                    _setMainHovering(false);
                    _setQuizHovering(true);
                  }
                },
                onExit: (_) {
                  if (hasQuiz) {
                    _setMainHovering(true);
                    _setQuizHovering(false);
                  }
                },
                child: GestureDetector(
                  onTap: widget.onQuizTap,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.mainRadius),
                          topRight: Radius.circular(widget.mainRadius),
                          bottomLeft: Radius.circular(widget.mainRadius),
                          bottomRight: Radius.circular(widget.designRadius)),
                      color: _quizHovering ? quizHover : background,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: (18 - widget.quizButtonMargin) / 2),
                      child: Row(children: [
                        const Text(' ',
                            style: TextStyle(
                                fontSize: 18, color: Colors.transparent)),
                        Text('Quiz',
                            style: TextStyle(
                                color: hasQuiz ? null : disabled,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Icon(Icons.launch_rounded,
                            size: 17, color: hasQuiz ? rankingColor : disabled),
                        const Text(' ',
                            style: TextStyle(
                                fontSize: 18, color: Colors.transparent)),
                      ]),
                    ),
                  ),
                ),
              ),
              SizedBox(height: widget.quizButtonMargin),
            ]),
          ]),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(widget.designRadius * 2),
                  bottomLeft: Radius.circular(widget.mainRadius),
                  bottomRight: Radius.circular(widget.mainRadius)),
              color: mainColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                        spacing: 20,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(widget.meaning,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: const Color(0xFFB5B6B2),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700))),
                          if (widget.showRanking)
                            Row(children: [
                              Icon(Icons.emoji_events_outlined,
                                  size: 17, color: rankingColor),
                              const SizedBox(width: 3),
                              widget.ranking == null
                                  ? SizedBox(
                                      width: 9,
                                      height: 1.6,
                                      child: ColoredBox(color: rankingColor))
                                  : Text('${widget.ranking}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: rankingColor)),
                            ]),
                        ]),
                    if (widget.supplementary case final content?) content,
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _NotchCorner extends StatelessWidget {
  const _NotchCorner({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(16, 16), painter: _NotchPainter(color));
}

class _NotchPainter extends CustomPainter {
  const _NotchPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..arcToPoint(Offset.zero, radius: const Radius.circular(16))
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
        Path()
          ..moveTo(-1, 0)
          ..lineTo(-1, size.height + 1)
          ..lineTo(size.width, size.height + 1),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant _NotchPainter oldDelegate) =>
      oldDelegate.color != color;
}
