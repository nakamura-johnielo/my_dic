import 'package:flutter/material.dart';
import 'package:my_dic/core/ui/search_result_card_shell.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const MyDicWidgetbook());

class MyDicWidgetbook extends StatelessWidget {
  const MyDicWidgetbook({super.key});

  @override
  Widget build(BuildContext context) => Widgetbook.material(
        directories: [
          WidgetbookFolder(
            name: 'Core UI',
            children: [
              WidgetbookComponent(
                name: 'SearchResultCardShell',
                useCases: [
                  WidgetbookUseCase(
                    name: 'Interactive',
                    builder: _buildSearchResultCardShell,
                  ),
                ],
              ),
            ],
          ),
        ],
        addons: [
          MaterialThemeAddon(
            themes: [
              WidgetbookTheme(name: 'Light', data: _lightTheme),
              WidgetbookTheme(name: 'Dark', data: _darkTheme),
            ],
          ),
          AlignmentAddon(),
        ],
      );
}

Widget _buildSearchResultCardShell(BuildContext context) {
  final knobs = context.knobs;
  final status = knobs.object.segmented<String>(
    label: 'Status',
    options: const ['Learning', 'Mastered', 'None'],
    initialOption: 'Learning',
  );
  final showSupplementary = knobs.boolean(
    label: 'Show supplementary content',
    initialValue: true,
  );

  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 480),
    child: SearchResultCardShell(
      word: knobs.string(label: 'Word', initialValue: 'serendipity'),
      meaning: knobs.string(
        label: 'Meaning',
        initialValue: '思いがけない幸運な発見',
      ),
      status: const SizedBox.shrink(),//_StatusLabel(status: status),
      onTap: knobs.boolean(label: 'Enable card tap', initialValue: true)
          ? () {}
          : null,
      onQuizTap: knobs.boolean(label: 'Enable quiz', initialValue: true)
          ? () {}
          : null,
      ranking: knobs.intOrNull.input(
        label: 'Ranking',
        initialValue: 12,
      ),
      showRanking: knobs.boolean(label: 'Show ranking', initialValue: true),
      supplementary: showSupplementary
          ? Text(
              knobs.string(
                label: 'Supplementary text',
                initialValue: 'noun  \u2022  C1',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      quizButtonMargin: knobs.double.slider(
        label: 'Quiz button margin',
        initialValue: 5,
        max: 12,
      ),
      mainRadius: knobs.double.slider(
        label: 'Main radius',
        initialValue: 16,
        max: 32,
      ),
      designRadius: knobs.double.slider(
        label: 'Design radius',
        initialValue: 4,
        max: 16,
      ),
    ),
  );
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'None') return const SizedBox.shrink();

    final color = status == 'Mastered' ? Colors.green : Colors.orange;
    return Align(
      alignment: Alignment.centerRight,
      child: Icon(Icons.bookmark_rounded, size: 18, color: color),
    );
  }
}

final _lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A4505)),
  useMaterial3: true,
);

final _darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF9ACA7A),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
