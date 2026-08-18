import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';
import 'package:my_dic/features/catalog/port/model/catalog_semantic_content.dart';
import 'package:my_dic/features/catalog/port/model/catalog_semantic_entry_detail.dart';
import 'package:my_dic/features/catalog/port/model/esp_jpn_entry.dart';
import 'package:my_dic/features/catalog/port/model/jpn_esp_entry.dart';

/// Converts Catalog-owned source markup into structured semantic content.
final class CatalogSemanticContentMapper {
  const CatalogSemanticContentMapper();

  CatalogSemanticEntryDetail detail(CatalogEntryDetail source) =>
      switch (source) {
        EspJpnEntryDetail(:final word, :final entries) =>
          CatalogSemanticEspJpnEntryDetail(
            word: word,
            entries: entries.map(_espJpnEntry),
          ),
        JpnEspEntryDetail(:final word, :final entries) =>
          CatalogSemanticJpnEspEntryDetail(
            word: word,
            entries: entries.map(_jpnEspEntry),
          ),
      };

  CatalogSemanticContent content(String? source) {
    if (source == null || source.isEmpty) return CatalogSemanticContent([]);
    final root = _parse(source);
    return CatalogSemanticContent(
      root.children.expand(_semanticNodes),
    );
  }

  CatalogSemanticEspJpnEntry _espJpnEntry(EspJpnEntry source) =>
      CatalogSemanticEspJpnEntry(
        dictionaryId: source.dictionaryId,
        word: source.word,
        headword: content(source.headword ?? source.word),
        content: content(source.content),
        origin: source.origin == null ? null : content(source.origin),
        examples: source.examples.map(
          (example) => CatalogSemanticEspJpnExample(
            exampleId: example.exampleId,
            espanol: example.espanol,
            japanese: example.japanese,
          ),
        ),
        idioms: source.idioms.map(
          (idiom) => CatalogSemanticIdiom(
            idiomId: idiom.idiomId,
            idiom: idiom.idiom,
            description: content(idiom.description),
          ),
        ),
        supplements: source.supplements.map(
          (supplement) => CatalogSemanticSupplement(
            supplementId: supplement.supplementId,
            content: content(supplement.supplement),
          ),
        ),
      );

  CatalogSemanticJpnEspEntry _jpnEspEntry(JpnEspEntry source) =>
      CatalogSemanticJpnEspEntry(
        dictionaryId: source.dictionaryId,
        wordId: source.wordId,
        word: source.word,
        headword: content(source.headword ?? source.word),
        content: content(source.content),
        examples: source.examples.map(
          (example) => CatalogSemanticJpnEspExample(
            exampleId: example.exampleId,
            japanese: example.japanese,
            espanol: example.espanol,
            espanolContent: content(example.espanolHtml),
          ),
        ),
      );
}

_HtmlElement _parse(String source) {
  final root = _HtmlElement('root', const {});
  final stack = <_HtmlElement>[root];
  final tokens = RegExp(r'<!--[\s\S]*?-->|<[^>]*>|[^<]+').allMatches(source);
  for (final match in tokens) {
    final token = match.group(0)!;
    if (token.startsWith('<!--')) continue;
    if (!token.startsWith('<')) {
      final text = _decodeEntities(token).replaceAll(RegExp(r'\s+'), ' ');
      if (text.isNotEmpty) stack.last.children.add(_HtmlText(text));
      continue;
    }

    final closing = RegExp(r'^<\s*/\s*([a-z][\w:-]*)', caseSensitive: false)
        .firstMatch(token);
    if (closing != null) {
      final tag = closing.group(1)!.toLowerCase();
      for (var index = stack.length - 1; index > 0; index--) {
        if (stack[index].tag != tag) continue;
        stack.removeRange(index, stack.length);
        break;
      }
      continue;
    }

    final opening = RegExp(r'^<\s*([a-z][\w:-]*)\b([^>]*)>',
            caseSensitive: false)
        .firstMatch(token);
    if (opening == null) continue;
    final tag = opening.group(1)!.toLowerCase();
    final element = _HtmlElement(tag, _attributes(opening.group(2)!));
    stack.last.children.add(element);
    if (!token.endsWith('/>') && !_voidTags.contains(tag)) {
      stack.add(element);
    }
  }
  return root;
}

Map<String, String> _attributes(String source) {
  final result = <String, String>{};
  final pattern = RegExp(
    r'''\b([\w:-]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))''',
  );
  for (final match in pattern.allMatches(source)) {
    result[match.group(1)!.toLowerCase()] =
        match.group(2) ?? match.group(3) ?? match.group(4) ?? '';
  }
  return result;
}

Iterable<CatalogContentNode> _semanticNodes(_HtmlNode node) sync* {
  if (node case _HtmlText(:final text)) {
    yield CatalogContentText(text);
    return;
  }
  final element = node as _HtmlElement;
  final children = element.children.expand(_semanticNodes).toList();
  final roles = _roles(element.attributes);
  switch (element.tag) {
    case 'br':
      yield const CatalogContentLineBreak();
      return;
    case 'img':
      final source = element.attributes['src'];
      if (source != null && source.isNotEmpty) {
        yield CatalogContentImage(
          source: source,
          description: element.attributes['alt'],
        );
      }
      return;
    case 'a':
      yield CatalogContentLink(
        target: element.attributes['href'],
        children: children,
      );
      return;
    case 'p':
      yield CatalogContentGroup(
        kind: CatalogContentGroupKind.paragraph,
        roles: roles,
        children: children,
      );
      return;
    case 'div':
      yield CatalogContentGroup(
        kind: CatalogContentGroupKind.section,
        roles: roles,
        children: children,
      );
      return;
    case 'b' || 'strong':
      yield CatalogContentGroup(
        kind: CatalogContentGroupKind.strong,
        roles: roles,
        children: children,
      );
      return;
    case 'i':
      yield CatalogContentGroup(
        kind: CatalogContentGroupKind.italic,
        roles: roles,
        children: children,
      );
      return;
    case 'em':
      yield CatalogContentGroup(
        kind: CatalogContentGroupKind.emphasis,
        roles: roles,
        children: children,
      );
      return;
    case 'small':
      yield CatalogContentGroup(
        kind: CatalogContentGroupKind.small,
        roles: roles,
        children: children,
      );
      return;
    case 'sup':
      yield CatalogContentGroup(
        kind: CatalogContentGroupKind.superscript,
        roles: roles,
        children: children,
      );
      return;
    case 'sub':
      yield CatalogContentGroup(
        kind: CatalogContentGroupKind.subscript,
        roles: roles,
        children: children,
      );
      return;
    default:
      if (children.isNotEmpty) {
        yield CatalogContentGroup(
          kind: CatalogContentGroupKind.inline,
          roles: {
            ...roles,
            if (element.tag == 'ref') CatalogContentRole.reference,
            if (element.tag == 'glabel') CatalogContentRole.grammarLabel,
          },
          children: children,
        );
      }
      return;
  }
}

Set<CatalogContentRole> _roles(Map<String, String> attributes) {
  final roles = <CatalogContentRole>{};
  switch (attributes['data-orgtag']?.trim()) {
    case 'meaning':
      roles.add(CatalogContentRole.meaning);
      break;
    case 'example':
      roles.add(CatalogContentRole.example);
      break;
    case 'subhead':
      roles.add(CatalogContentRole.subhead);
      break;
    case 'subheadword':
      roles.add(CatalogContentRole.subheadword);
      break;
    case 'column':
      roles.add(CatalogContentRole.column);
      break;
    case 'title':
      roles.add(CatalogContentRole.title);
      break;
  }
  switch (attributes['type']?.trim()) {
    case '品詞区分':
      roles.add(CatalogContentRole.partOfSpeech);
      break;
    case '再帰動詞':
      roles.add(CatalogContentRole.reflexive);
      break;
    case '成句' || '慣用':
      roles.add(CatalogContentRole.idiom);
      break;
    case '語源':
      roles.add(CatalogContentRole.origin);
      break;
    case '補足':
      roles.add(CatalogContentRole.supplement);
      break;
    case '類語':
      roles.add(CatalogContentRole.synonym);
      break;
    case '関連' || '関連語':
      roles.add(CatalogContentRole.related);
      break;
    case '合成語':
      roles.add(CatalogContentRole.compound);
      break;
    case '派生語':
      roles.add(CatalogContentRole.derivative);
      break;
    case '用法':
      roles.add(CatalogContentRole.usage);
      break;
    case '諺':
      roles.add(CatalogContentRole.proverb);
      break;
    case 'コラム':
      roles.add(CatalogContentRole.column);
      break;
    case '中見出し':
      roles.add(CatalogContentRole.middleHeading);
      break;
    case '参考':
      roles.add(CatalogContentRole.reference);
      break;
  }
  return roles;
}

String _decodeEntities(String value) => value.replaceAllMapped(
      RegExp(r'&(#(?:x[0-9a-f]+|[0-9]+)|[a-z]+);', caseSensitive: false),
      (match) => _decodeEntity(match.group(1)!) ?? match.group(0)!,
    );

String? _decodeEntity(String entity) {
  if (entity.startsWith('#x') || entity.startsWith('#X')) {
    final value = int.tryParse(entity.substring(2), radix: 16);
    return value == null ? null : String.fromCharCode(value);
  }
  if (entity.startsWith('#')) {
    final value = int.tryParse(entity.substring(1));
    return value == null ? null : String.fromCharCode(value);
  }
  return const {
    'amp': '&',
    'apos': "'",
    'gt': '>',
    'lt': '<',
    'nbsp': ' ',
    'quot': '"',
  }[entity.toLowerCase()];
}

sealed class _HtmlNode {}

final class _HtmlText extends _HtmlNode {
  _HtmlText(this.text);
  final String text;
}

final class _HtmlElement extends _HtmlNode {
  _HtmlElement(this.tag, this.attributes);
  final String tag;
  final Map<String, String> attributes;
  final List<_HtmlNode> children = [];
}

const _voidTags = {
  'area',
  'base',
  'br',
  'col',
  'embed',
  'hr',
  'img',
  'input',
  'link',
  'meta',
  'param',
  'source',
  'track',
  'wbr',
};
