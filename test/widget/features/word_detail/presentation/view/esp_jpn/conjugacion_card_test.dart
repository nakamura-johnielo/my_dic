import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/word_detail/internal/presentation/components/conjugacion_card.dart';

void main() {
  const forms = {
    CatalogSubject.yo: 'hablo',
    CatalogSubject.tu: 'hablas',
    CatalogSubject.el: 'habla',
    CatalogSubject.nosotros: 'hablamos',
    CatalogSubject.vosotros: 'habláis',
    CatalogSubject.ellos: 'hablan',
  };

  testWidgets('uses catalog labels and preserves the established subject order',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConjugacionCard(
          moodTense: CatalogMoodTense.indicativePresent,
          conjugacion: CatalogTenseConjugation(forms: forms),
        ),
      ),
    );

    expect(find.text('【直説法】 現在'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Yo')).dy,
      lessThan(tester.getTopLeft(find.text('Tú')).dy),
    );
    expect(find.text('Él/Ella/Usted'), findsOneWidget);
    expect(find.text('hablamos'), findsOneWidget);
  });

  testWidgets('uses the catalog participle label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ParticipleCard(
          moodTense: CatalogMoodTense.participlePast,
          conjugacion: 'hablado',
        ),
      ),
    );

    expect(find.text('過去分詞'), findsOneWidget);
    expect(find.text('hablado'), findsOneWidget);
  });
}
