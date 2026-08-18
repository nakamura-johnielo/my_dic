import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_semantic_content_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_semantic_entry_detail_reader.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

void main() {
  const mapper = CatalogSemanticContentMapper();

  test('preserves hierarchy, roles, emphasis, links, breaks, and images', () {
    final content = mapper.content('''
      <div data-orgtag="subhead" type="成句">
        <p data-orgtag="meaning"><b>take</b> <i>care</i><br>
          <a href="entry:2">linked</a><img src="asset.png" alt="diagram">
        </p>
      </div>
    ''');

    final nodes = _walk(content.nodes).toList();
    final section = content.nodes
        .whereType<CatalogContentGroup>()
        .single;
    expect(section.kind, CatalogContentGroupKind.section);
    expect(
      section.roles,
      {CatalogContentRole.subhead, CatalogContentRole.idiom},
    );
    expect(
      nodes.whereType<CatalogContentGroup>().map((node) => node.kind),
      containsAll([
        CatalogContentGroupKind.paragraph,
        CatalogContentGroupKind.strong,
        CatalogContentGroupKind.italic,
      ]),
    );
    expect(nodes.whereType<CatalogContentLineBreak>(), hasLength(1));
    expect(nodes.whereType<CatalogContentLink>().single.target, 'entry:2');
    expect(nodes.whereType<CatalogContentImage>().single.source, 'asset.png');
    expect(
      nodes.whereType<CatalogContentText>().map((node) => node.text).join(),
      isNot(contains('<')),
    );
  });

  test('maps every raw detail field to semantic Catalog-owned content', () {
    const word = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 7,
    );
    final detail = mapper.detail(EspJpnEntryDetail(
      word: word,
      entries: [
        EspJpnEntry(
          dictionaryId: 8,
          word: 'hablar',
          headword: '<i>hablar</i><sup>(**)</sup>',
          content: '<p data-orgtag="meaning"><b>speak</b></p>',
          origin: '<i>lat.</i>',
          idioms: const [
            EspJpnIdiom(
              idiomId: 9,
              idiom: 'hablar claro',
              description: '<p><b>speak plainly</b></p>',
            ),
          ],
          supplements: const [
            CatalogSupplement(
              supplementId: 10,
              supplement: '<i>usage</i>',
            ),
          ],
        ),
      ],
    ));

    expect(detail, isA<CatalogSemanticEspJpnEntryDetail>());
    final entry =
        (detail as CatalogSemanticEspJpnEntryDetail).espJpnEntries.single;
    expect(_text(entry.headword), contains('hablar'));
    expect(_text(entry.content), contains('speak'));
    expect(_text(entry.origin!), contains('lat.'));
    expect(_text(entry.idioms.single.description), contains('speak plainly'));
    expect(_text(entry.supplements.single.content), contains('usage'));
  });

  test('focused semantic reader maps success and preserves source failure',
      () async {
    const word = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 7,
    );
    final reader = DriftCatalogSemanticEntryDetailQueryService(
      _DetailReader(Result.success(EspJpnEntryDetail(
        word: word,
        entries: [
          EspJpnEntry(
            dictionaryId: 1,
            word: 'hablar',
            content: '<p data-orgtag="meaning">speak</p>',
          ),
        ],
      ))),
    );

    final mapped = await reader.readSemanticEntryDetail(word);
    expect(mapped.dataOrNull, isA<CatalogSemanticEspJpnEntryDetail>());

    const error = CatalogDataUnavailableError(message: 'stable failure');
    final failed = await DriftCatalogSemanticEntryDetailQueryService(
      _DetailReader(Result.failure(error)),
    ).readSemanticEntryDetail(word);
    expect(failed.errorOrNull, same(error));
  });
}

final class _DetailReader implements CatalogEntryDetailQueryPort {
  const _DetailReader(this.result);

  final Result<CatalogEntryDetail> result;

  @override
  Future<Result<CatalogEntryDetail>> readEntryDetail(CatalogWordRef word) async =>
      result;
}

Iterable<CatalogContentNode> _walk(Iterable<CatalogContentNode> nodes) sync* {
  for (final node in nodes) {
    yield node;
    switch (node) {
      case CatalogContentGroup(:final children):
        yield* _walk(children);
      case CatalogContentLink(:final children):
        yield* _walk(children);
      case CatalogContentText() ||
            CatalogContentLineBreak() ||
            CatalogContentImage():
        break;
    }
  }
}

String _text(CatalogSemanticContent content) => _walk(content.nodes)
    .whereType<CatalogContentText>()
    .map((node) => node.text)
    .join();
