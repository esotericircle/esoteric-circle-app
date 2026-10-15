import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/lunario/il_giorno_lunare.dart';
import 'package:esoteric_circle/core/lunario/le_attivita_del_lunario.dart';
import 'package:esoteric_circle/features/lunario/la_card_del_mese.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA CARD DEL MESE NON PORTA DATI DI NASCITA.** Ordine FV voce FV.11, 15
/// ottobre 2026. La card esce dal telefono e la guardano altri: nessun
/// giorno tuo (FV.07) e nessuna intenzione (FV.09), perche' direbbero la
/// Luna o il Sole della nascita di chi condivide, o una riga privata.
///
/// La guardia che questa classe prometteva nel suo commento di testa e che
/// non era mai stata scritta: la card non era mai stata montata da nessuna
/// prova, e un difetto vero (la fascia della firma che traboccava) e'
/// arrivato fino alle anteprime prima di essere trovato.
List<GiornoLunare> _ottobre(int anno, int mese) {
  final n = DateTime(anno, mese + 1, 0).day;
  return [
    for (var d = 1; d <= n; d++)
      GiornoLunare(
        giorno: DateTime(anno, mese, d),
        elongazione: (d * 12.0) % 360,
        illuminazione: 0.5,
        crescente: true,
        fase: FaseLunare.crescente,
        segno: Zodiac.leo,
        cambiDiSegno: const [],
        fuoriCorso: const [],
        giornoLunare: d,
        tipoBiodinamico: null,
        lunaNuova: false,
        lunaPiena: false,
      ),
  ];
}

void main() {
  test('nessun codice della card nomina i giorni tuoi o l\'intenzione', () {
    final f = File('lib/features/lunario/la_card_del_mese.dart');
    final soloCodice = f
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trim().startsWith('//') && !r.trim().startsWith('*'))
        .join('\n');
    const vietati = [
      'SegnoDelGiornoTuo',
      'TipoDelGiornoTuo',
      'IGiorniTuoiDelMese',
      'intenzione',
      'Intenzione',
    ];
    final trovati = [for (final v in vietati) if (soloCodice.contains(v)) v];
    expect(trovati, isEmpty,
        reason: 'la card del mese nomina nel codice (non nei commenti) '
            'qualcosa di FV.07 o FV.09: $trovati');
  });

  testWidgets(
      'la card renderizza alla larghezza vera senza eccezioni, con e senza '
      'un\'attivita\' scelta', (tester) async {
    Future<void> monta({AttivitaDelLunario? attivita, Set<int> oro = const {}}) {
      return tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: LaCardDelMese(
              anno: 2026,
              mese: 10,
              giorni: _ottobre(2026, 10),
              ruota: false,
              attivita: attivita,
              giorniDOro: oro,
              // La larghezza vera, quella che usa la schermata: nessun
              // parametro esplicito (il default della classe).
            ),
          ),
        ),
      ));
    }

    await monta();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull,
        reason: 'la card senza attivita\' lancia un\'eccezione di layout '
            '(per esempio un trabocco nella fascia della firma)');

    await monta(attivita: AttivitaDelLunario.semina, oro: {12, 20});
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull,
        reason: 'la card con un\'attivita\' scelta lancia un\'eccezione di '
            'layout');

    expect(find.byKey(const Key('card_mese')), findsOneWidget);
    expect(find.byKey(const Key('card_mese_collegamento')), findsOneWidget);
  });
}
