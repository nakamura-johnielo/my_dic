import 'package:my_dic/features/catalog/port/model/catalog_frequency_level.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';

final class CatalogEntrySummaryMapper {
  const CatalogEntrySummaryMapper();

  CatalogMeaningSummary? meaning(
    String html, {
    required bool isConjugation,
  }) {
    final meaning = isConjugation ? _plainText(html) : extractMeaningText(html);
    return meaning.isEmpty ? null : CatalogMeaningSummary(meaning: meaning);
  }

  CatalogHeadwordMetadata headword(String headwordHtml) {
    final frequencyMatch = RegExp(
      r'<sup\b[^>]*>\s*\((\*+)\)\s*</sup>',
      caseSensitive: false,
    ).firstMatch(headwordHtml);
    final withoutFrequency = headwordHtml.replaceAll(
      RegExp(
        r'<sup\b[^>]*>\s*\(\*+\)\s*</sup>',
        caseSensitive: false,
      ),
      '',
    );
    return CatalogHeadwordMetadata(
      headword: _plainText(withoutFrequency),
      frequencyLevel:
          CatalogFrequencyLevel(frequencyMatch?.group(1)!.length ?? 0),
    );
  }

  CatalogRankingMetadata ranking(int rankingNo) =>
      CatalogRankingMetadata(rankingNo: rankingNo);

  /// 完全な辞書の意味要素をすべて正規化済みテキストとして抽出する。
  String extractMeaningText(String html) {
    final meanings = <String>[];
    final elements = <_HtmlElement>[];
    _MeaningFrame? activeMeaning;
    for (final match
        in RegExp(r'<!--[\s\S]*?-->|<[^>]*>|[^<]+').allMatches(html)) {
      final token = match.group(0)!;
      if (!token.startsWith('<')) {
        activeMeaning?.text.write(token);
        continue;
      }
      final closing = RegExp(r'^<\s*/\s*([a-z][\w:-]*)', caseSensitive: false)
          .firstMatch(token);
      if (closing != null) {
        final tag = closing.group(1)!.toLowerCase();
        while (elements.isNotEmpty) {
          final element = elements.removeLast();
          if (_isTextBoundary(element.tag)) activeMeaning?.text.write(' ');
          if (element.meaning case final frame?) {
            final meaning = _plainText(frame.text.toString());
            if (meaning.isNotEmpty) meanings.add(meaning);
            activeMeaning = null;
          }
          if (element.tag == tag) break;
        }
        continue;
      }
      final opening = RegExp(r'^<\s*([a-z][\w:-]*)\b', caseSensitive: false)
          .firstMatch(token);
      if (opening == null || token.startsWith('<!--')) continue;
      final tag = opening.group(1)!.toLowerCase();
      if (_isTextBoundary(tag)) activeMeaning?.text.write(' ');
      final isMeaning = activeMeaning == null &&
          RegExp(
            r'''\bdata-orgtag\s*=\s*(?:"meaning"|'meaning')''',
            caseSensitive: false,
          ).hasMatch(token);
      final frame = isMeaning ? _MeaningFrame() : null;
      if (frame != null) activeMeaning = frame;
      if (!token.endsWith('/>') && !_isVoidElement(tag)) {
        elements.add(_HtmlElement(tag, frame));
      } else if (frame != null) {
        activeMeaning = null;
      }
    }
    return meanings.join('  ');
  }
}

final class _HtmlElement {
  const _HtmlElement(this.tag, this.meaning);

  final String tag;
  final _MeaningFrame? meaning;
}

final class _MeaningFrame {
  final StringBuffer text = StringBuffer();
}

bool _isTextBoundary(String tag) => const {
      'br',
      'p',
      'div',
      'li',
      'tr',
      'h1',
      'h2',
      'h3',
      'h4',
      'h5',
      'h6'
    }.contains(tag);

bool _isVoidElement(String tag) => const {
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
      'wbr'
    }.contains(tag);

String _plainText(String html) {
  final withBreaks = html.replaceAll(
    RegExp(r'<(?:br|/p|/div|/li|/tr|/h[1-6])\b[^>]*>', caseSensitive: false),
    ' ',
  );
  final withoutTags = withBreaks.replaceAll(RegExp(r'<[^>]*>'), '');
  final decoded = withoutTags.replaceAllMapped(
    RegExp(r'&(#(?:x[0-9a-f]+|[0-9]+)|[a-z]+);', caseSensitive: false),
    (match) => _decodeEntity(match.group(1)!) ?? match.group(0)!,
  );
  return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
}

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
