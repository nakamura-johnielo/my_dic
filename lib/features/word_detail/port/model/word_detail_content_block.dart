/// Provider-neutral semantic dictionary content.
final class WordDetailContent {
  WordDetailContent(Iterable<WordDetailContentBlock> blocks)
      : blocks = List.unmodifiable(blocks);

  WordDetailContent.text(String text)
      : blocks = List.unmodifiable([WordDetailTextBlock(text)]);

  final List<WordDetailContentBlock> blocks;
}

sealed class WordDetailContentBlock {
  const WordDetailContentBlock();
}

final class WordDetailTextBlock extends WordDetailContentBlock {
  const WordDetailTextBlock(this.text);

  final String text;
}

enum WordDetailContentGroupKind {
  section,
  paragraph,
  inline,
  strong,
  italic,
  emphasis,
  small,
  superscript,
  subscript,
}

enum WordDetailContentRole {
  meaning,
  example,
  subhead,
  subheadword,
  partOfSpeech,
  reflexive,
  idiom,
  origin,
  supplement,
  synonym,
  related,
  compound,
  derivative,
  usage,
  proverb,
  column,
  title,
  middleHeading,
  reference,
  grammarLabel,
}

final class WordDetailGroupBlock extends WordDetailContentBlock {
  WordDetailGroupBlock({
    required this.kind,
    Iterable<WordDetailContentRole> roles = const [],
    required Iterable<WordDetailContentBlock> children,
  })  : roles = Set.unmodifiable(roles),
        children = List.unmodifiable(children);

  final WordDetailContentGroupKind kind;
  final Set<WordDetailContentRole> roles;
  final List<WordDetailContentBlock> children;
}

final class WordDetailLineBreakBlock extends WordDetailContentBlock {
  const WordDetailLineBreakBlock();
}

final class WordDetailLinkBlock extends WordDetailContentBlock {
  WordDetailLinkBlock({
    required this.target,
    required Iterable<WordDetailContentBlock> children,
  }) : children = List.unmodifiable(children);

  final String? target;
  final List<WordDetailContentBlock> children;
}

final class WordDetailImageBlock extends WordDetailContentBlock {
  const WordDetailImageBlock({required this.source, this.description});

  final String source;
  final String? description;
}
