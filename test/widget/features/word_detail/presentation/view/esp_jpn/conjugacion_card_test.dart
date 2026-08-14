import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/word_detail/internal/presentation/components/conjugacion_card.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

void main() {
  const forms = {
    WordDetailSubject.yo: 'hablo',
    WordDetailSubject.tu: 'hablas',
    WordDetailSubject.el: 'habla',
    WordDetailSubject.nosotros: 'hablamos',
    WordDetailSubject.vosotros: 'habláis',
    WordDetailSubject.ellos: 'hablan',
  };

  testWidgets('uses detail labels and preserves the established subject order',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ConjugacionCard(
        moodTense: WordDetailMoodTense.indicativePresent,
        conjugacion: WordDetailTenseConjugation(forms: forms),
      ),
    ));

    expect(find.text('【直説法】 現在'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Yo')).dy,
      lessThan(tester.getTopLeft(find.text('Tú')).dy),
    );
    expect(find.text('Él/Ella/Usted'), findsOneWidget);
    expect(find.text('hablamos'), findsOneWidget);
  });

  testWidgets('uses the detail participle label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ParticipleCard(
        moodTense: WordDetailMoodTense.participlePast,
        conjugacion: 'hablado',
      ),
    ));

    expect(find.text('過去分詞'), findsOneWidget);
    expect(find.text('hablado'), findsOneWidget);
  });
}
