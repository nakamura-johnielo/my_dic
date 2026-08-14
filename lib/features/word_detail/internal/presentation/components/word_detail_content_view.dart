import 'package:flutter/material.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// Renders WordDetail-owned semantic content without accepting source markup.
final class WordDetailContentView extends StatelessWidget {
  const WordDetailContentView({
    super.key,
    required this.content,
    this.isHeadword = false,
  });

  final WordDetailContent content;
  final bool isHeadword;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
        style: isHeadword
            ? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            : const TextStyle(height: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: content.blocks
              .map((block) => _ContentBlockView(block: block))
              .toList(growable: false),
        ),
      );
}

final class _ContentBlockView extends StatelessWidget {
  const _ContentBlockView({required this.block});

  final WordDetailContentBlock block;

  @override
  Widget build(BuildContext context) {
    if (block case WordDetailImageBlock(
      :final source,
      :final description,
    )) {
      return Semantics(
        label: description,
        image: true,
        child: Image.network(
          source,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    }

    final group = block is WordDetailGroupBlock
        ? block as WordDetailGroupBlock
        : null;
    final padding = group == null ? EdgeInsets.zero : _padding(group.roles);
    return Padding(
      padding: padding,
      child: Text.rich(
        _span(block, DefaultTextStyle.of(context).style),
      ),
    );
  }
}

InlineSpan _span(WordDetailContentBlock block, TextStyle baseStyle) =>
    switch (block) {
      WordDetailTextBlock(:final text) => TextSpan(text: text),
      WordDetailLineBreakBlock() => const TextSpan(text: '\n'),
      WordDetailLinkBlock(:final children) => TextSpan(
          style: const TextStyle(decoration: TextDecoration.underline),
          children: children.map((child) => _span(child, baseStyle)).toList(),
        ),
      WordDetailImageBlock(:final source, :final description) => WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Semantics(
            label: description,
            image: true,
            child: Image.network(
              source,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      WordDetailGroupBlock(:final kind, :final roles, :final children) =>
        TextSpan(
          style: _style(baseStyle, kind, roles),
          children: children.map((child) => _span(child, baseStyle)).toList(),
        ),
    };

TextStyle _style(
  TextStyle base,
  WordDetailContentGroupKind kind,
  Set<WordDetailContentRole> roles,
) {
  var style = switch (kind) {
    WordDetailContentGroupKind.strong =>
      const TextStyle(fontWeight: FontWeight.bold),
    WordDetailContentGroupKind.italic ||
    WordDetailContentGroupKind.emphasis =>
      const TextStyle(fontStyle: FontStyle.italic),
    WordDetailContentGroupKind.small => const TextStyle(fontSize: 12),
    WordDetailContentGroupKind.superscript ||
    WordDetailContentGroupKind.subscript =>
      const TextStyle(fontSize: 11),
    _ => const TextStyle(),
  };
  if (roles.contains(WordDetailContentRole.partOfSpeech) ||
      roles.contains(WordDetailContentRole.reflexive)) {
    style = style.merge(const TextStyle(fontSize: 18));
  }
  if (roles.contains(WordDetailContentRole.subheadword) &&
      roles.contains(WordDetailContentRole.idiom)) {
    style = style.merge(const TextStyle(fontWeight: FontWeight.bold));
  }
  return base.merge(style);
}

EdgeInsets _padding(Set<WordDetailContentRole> roles) {
  if (roles.contains(WordDetailContentRole.partOfSpeech) ||
      roles.contains(WordDetailContentRole.reflexive)) {
    return const EdgeInsets.only(top: 30);
  }
  if (roles.contains(WordDetailContentRole.idiom) &&
      roles.contains(WordDetailContentRole.subhead)) {
    return const EdgeInsets.only(top: 20, left: 10);
  }
  if (roles.contains(WordDetailContentRole.meaning)) {
    return const EdgeInsets.only(top: 10);
  }
  if (roles.contains(WordDetailContentRole.supplement)) {
    return const EdgeInsets.only(left: 20);
  }
  if (roles.contains(WordDetailContentRole.example)) {
    return const EdgeInsets.only(left: 15);
  }
  return EdgeInsets.zero;
}
