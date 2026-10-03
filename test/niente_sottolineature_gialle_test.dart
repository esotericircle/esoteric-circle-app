import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/synastry/ritratto_ingrandito.dart';
import 'package:esoteric_circle/features/tarot/carta_ingrandita.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// NIENTE SOTTOLINEATURE GIALLE. Ordine BV voce 01.
///
/// **Parole del fondatore sulla build 2209**: "il testo sottolineato di giallo
/// c'e' ancora quando apro una carta e quando apro un ritratto".
///
/// **LA CAUSA NON ERA LA TRASPARENZA.** L'ordine BU aveva reso il velo nero
/// pieno credendo che le righe fossero cio' che si vedeva attraverso, e il
/// fondatore le ha riviste lo stesso: erano righe DISEGNATE. Un testo senza un
/// `Material` fra i suoi antenati non trova nessun `DefaultTextStyle` vestito e
/// ricade su quello di sistema, che porta una doppia sottolineatura gialla; e
/// una rotta aperta con `showGeneralDialog` un `Material` non ce l'ha.
///
/// Qui si misura la cosa vera: **lo stile che ogni testo di quelle due scene
/// eredita davvero**, e il numero di testi che ricadono su quello di sistema.
void main() {
  /// Quanti testi, dentro la scena, ereditano la sottolineatura di sistema.
  ({int scoperti, int totali, List<String> esempi}) contaScoperti(
      WidgetTester tester) {
    var totali = 0;
    var scoperti = 0;
    final esempi = <String>[];
    for (final e in find.byType(Text).evaluate()) {
      totali++;
      final w = e.widget as Text;
      // Un testo che si sottolinea da solo e' una scelta, non un difetto.
      if (w.style?.decoration != null) continue;
      final ereditato = DefaultTextStyle.of(e).style;
      final senzaMaterial = Material.maybeOf(e) == null;
      if (ereditato.decoration == TextDecoration.underline || senzaMaterial) {
        scoperti++;
        if (esempi.length < 3) {
          esempi.add('"${w.data ?? ""}" con ${ereditato.decoration} e '
              'colore ${ereditato.decorationColor}');
        }
      }
    }
    return (scoperti: scoperti, totali: totali, esempi: esempi);
  }

  Future<void> apri(
      WidgetTester tester, Future<void> Function(BuildContext) porta) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold(body: SizedBox.expand());
      }),
    ));
    porta(ctx);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('BV.01: la carta aperta non eredita la riga gialla',
      (tester) async {
    final lettura = TarotReading.of(
      TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: 2)),
      TarotTopic.bivio,
    );
    await apri(
        tester,
        (c) => mostraLaCartaIngrandita(c,
            letta: lettura.posizioni.first, palette: MaestroPalette.medora));
    final conto = contaScoperti(tester);
    // ignore: avoid_print
    print('ORDINE BV VOCE 1: nella carta aperta, testi che ricadono sullo '
        'stile di sistema ${conto.scoperti} su ${conto.totali}'
        '${conto.esempi.isEmpty ? "" : " (${conto.esempi.join("; ")})"}');
    expect(conto.totali, greaterThan(0),
        reason: 'la carta aperta non ha nessun testo: la prova non sta '
            'guardando la scena giusta');
    expect(conto.scoperti, 0,
        reason: 'nella carta aperta ci sono ${conto.scoperti} testi senza un '
            'Material sopra: sono le righe gialle che il fondatore vede');
  });

  testWidgets('BV.01: il ritratto aperto non eredita la riga gialla',
      (tester) async {
    await apri(
        tester,
        (c) => mostraIlRitrattoIngrandito(c,
            vip: VipCatalog.first, palette: MaestroPalette.medora));
    final conto = contaScoperti(tester);
    // ignore: avoid_print
    print('ORDINE BV VOCE 1: nel ritratto aperto, testi che ricadono sullo '
        'stile di sistema ${conto.scoperti} su ${conto.totali}'
        '${conto.esempi.isEmpty ? "" : " (${conto.esempi.join("; ")})"}');
    expect(conto.totali, greaterThan(0),
        reason: 'il ritratto aperto non ha nessun testo: la prova non sta '
            'guardando la scena giusta');
    expect(conto.scoperti, 0,
        reason: 'nel ritratto aperto ci sono ${conto.scoperti} testi senza un '
            'Material sopra: sono le righe gialle che il fondatore vede');
  });

  test('Ogni rotta aperta a mano si veste da sola', () {
    // **L'ENUMERAZIONE DELLE PORTE.** Le rotte costruite con
    // `showGeneralDialog` nascono nude: qui si contano tutte quelle che ci
    // sono in `lib`, e ognuna deve dichiarare il suo `Material`. La terza che
    // nascera' domani non tornera' muta al difetto di oggi.
    final nude = <String>[];
    var quante = 0;
    for (final f in sorgentiDiLib()) {
      final testo = f.readAsStringSync();
      if (!testo.contains('showGeneralDialog')) continue;
      quante++;
      if (!testo.contains('Material(')) nude.add(f.path);
    }
    // ignore: avoid_print
    print('ORDINE BV VOCE 1: rotte aperte a mano in lib: $quante, senza un '
        'Material: ${nude.isEmpty ? "nessuna" : nude}');
    expect(quante, greaterThan(0),
        reason: 'non si trova nessuna rotta aperta a mano: il conto sta '
            'guardando nel posto sbagliato');
    expect(nude, isEmpty,
        reason: 'queste rotte nascono senza un Material, e i loro testi '
            'ricadranno sulla riga gialla di sistema: $nude');
  });
}
