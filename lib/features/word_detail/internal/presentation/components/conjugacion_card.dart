import 'package:flutter/material.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_conjugation_labels.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

class ConjugacionCard extends StatelessWidget {
  const ConjugacionCard({
    super.key,
    required this.moodTense,
    required this.conjugacion,
    this.query = '',
  });

  final WordDetailMoodTense moodTense;
  final WordDetailTenseConjugation conjugacion;
  final String query;

  Widget _highlightMatch(BuildContext context, String text) {
    if (query.isEmpty) return _text(text);

    final start = text.toLowerCase().indexOf(query.toLowerCase());
    if (start < 0) return _text(text);

    final end = start + query.length;
    final isExactMatch = text.length == query.length;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16),
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              backgroundColor: isExactMatch
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha: .5),
              color:
                  isExactMatch ? Theme.of(context).colorScheme.onPrimary : null,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _text(String text) => Text(text,
      style: const TextStyle(fontSize: 16), textAlign: TextAlign.left);

  @override
  Widget build(BuildContext context) => Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moodTense.label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final subject in wordDetailSubjectOrder) ...[
                          Text(subject.displayEsp, textAlign: TextAlign.left),
                          if (subject != wordDetailSubjectOrder.last)
                            const SizedBox(height: 5),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final subject in wordDetailSubjectOrder) ...[
                        _highlightMatch(context, conjugacion[subject] ?? ''),
                        if (subject != wordDetailSubjectOrder.last)
                          const SizedBox(height: 5),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class ParticipleCard extends StatelessWidget {
  const ParticipleCard({
    super.key,
    required this.moodTense,
    required this.conjugacion,
    this.query = '',
  });

  final WordDetailMoodTense moodTense;
  final String conjugacion;
  final String query;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
          child: Row(
            spacing: 15,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moodTense.label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(conjugacion, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
}
