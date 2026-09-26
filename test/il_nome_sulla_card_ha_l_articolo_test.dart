// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/card_della_rivelazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL NOME SULLA CARD HA IL SUO ARTICOLO, E STA SU UNA RIGA.**
/// Ordine DQ voce 14, 16 settembre 2026.
///
/// **Il fatto, dal fondatore**, guardando la card sul telefono: *"questo e'
/// molto fastidioso: «mi ha trovato volpe» anziche' «mi ha trovato la
/// volpe»"*. La card diceva `MI HA TROVATO ${nome}`, e quel nome usciva nudo:
/// in italiano il nome di un animale vuole l'articolo, e il codice lo sapeva
/// gia' fare, `GuideAnimal.articolo`, che elide anche davanti a vocale.
///
/// **E il nome va su una riga sua, piu' grande**, come ha chiesto il
/// fondatore: la card esce di casa, e il primo che si legge deve essere il
/// nome dell'animale.
void main() {
  test('la card dice il nome con l\'articolo, per tutti e dodici', () {
    final storti = <String>[];
    for (final a in AnimalCatalog.animals) {
      final nome = CardDellaRivelazione.ilNome(a);
      // **L'ARTICOLO C'E' E NON E' UN PEZZO DEL NOME**: la riga comincia con
      // LA, IL o L', e il nome viene dopo.
      final giusto = nome.startsWith("L'")
          ? nome == "L'${a.name.toUpperCase()}"
          : nome == '${a.femminile ? "LA" : "IL"} ${a.name.toUpperCase()}';
      if (!giusto) storti.add('${a.name}: "$nome"');
    }
    print('ORDINE DQ VOCE 14, IL NOME SULLA CARD: '
        '${AnimalCatalog.animals.map(CardDellaRivelazione.ilNome).join(", ")}');
    expect(AnimalCatalog.animals.length, 12);
    expect(storti, isEmpty,
        reason: 'questi nomi non portano il loro articolo: $storti');
    // **E IL TITOLO INTERO RESTA UNA FRASE**, per chi lo legge in una riga
    // sola: le prove e chi condivide la card.
    expect(CardDellaRivelazione.titolo(AnimalCatalog.animals.first),
        startsWith('MI HA TROVATO '));
  });

  testWidgets('il nome sta su una riga dentro la card, per tutti e dodici',
      (tester) async {
    // **LA CARD E' LARGA 320 PUNTI**, e dentro ci sta il nome piu' lungo:
    // *"LA TARTARUGA"*. Se domani il nome crescesse o la misura salisse, la
    // riga andrebbe a capo e la card si leggerebbe rotta.
    final lunghi = <String>[];
    for (final a in AnimalCatalog.animals) {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: CardDellaRivelazione(
            animale: a,
            quando: DateTime(2026, 9, 16),
          ),
        ),
      ));
      await tester.pump();
      final testo = tester.widget<Text>(
          find.byKey(const Key('card_rivelazione_nome')));
      final scatola =
          tester.getSize(find.byKey(const Key('card_rivelazione_nome')));
      final pittore = TextPainter(
        text: TextSpan(text: testo.data, style: testo.style),
        textDirection: TextDirection.ltr,
      )..layout();
      if (pittore.width > scatola.width + 0.5 ||
          pittore.height > scatola.height + 0.5) {
        lunghi.add('${testo.data}: ${pittore.width.toStringAsFixed(1)} punti '
            'in ${scatola.width.toStringAsFixed(1)}');
      }
    }
    expect(lunghi, isEmpty,
        reason: 'questi nomi non stanno su una riga nella card: $lunghi');
  });
}
