/// Structured dictionary content whose meaning does not depend on raw HTML.
final class CatalogSemanticContent {
  CatalogSemanticContent(Iterable<CatalogContentNode> nodes)
      : nodes = List.unmodifiable(nodes);

  CatalogSemanticContent.text(String text)
      : nodes = List.unmodifiable([CatalogContentText(text)]);

  final List<CatalogContentNode> nodes;
}

sealed class CatalogContentNode {
  const CatalogContentNode();
}

final class CatalogContentText extends CatalogContentNode {
  const CatalogContentText(this.text);

  final String text;
}

enum CatalogContentGroupKind {
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

enum CatalogContentRole {
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

final class CatalogContentGroup extends CatalogContentNode {
  CatalogContentGroup({
    required this.kind,
    Iterable<CatalogContentRole> roles = const [],
    required Iterable<CatalogContentNode> children,
  })  : roles = Set.unmodifiable(roles),
        children = List.unmodifiable(children);

  final CatalogContentGroupKind kind;
  final Set<CatalogContentRole> roles;
  final List<CatalogContentNode> children;
}

final class CatalogContentLineBreak extends CatalogContentNode {
  const CatalogContentLineBreak();
}

final class CatalogContentLink extends CatalogContentNode {
  CatalogContentLink({
    required this.target,
    required Iterable<CatalogContentNode> children,
  }) : children = List.unmodifiable(children);

  final String? target;
  final List<CatalogContentNode> children;
}

final class CatalogContentImage extends CatalogContentNode {
  const CatalogContentImage({required this.source, this.description});

  final String source;
  final String? description;
}
