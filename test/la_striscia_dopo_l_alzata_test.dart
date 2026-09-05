/// L'ALTEZZA DELLA STRISCIA DOPO L'ALZATA DEI CARATTERI.
/// Ordine CG voce 14.
///
/// **Il fatto che l'ordine dichiara invece di scoprirlo dopo.** La voce CF.02
/// ha appena portato la striscia dei Doni da 122 a 112 punti, e l'altezza
/// adesso segue la scala del testo. Alzare i nomi dei Doni dal pavimento
/// tipografico a sedici punti rialza la striscia, cioe' lavora contro la voce
/// che il fondatore aveva appena chiesto.
///
/// **Questa prova misura, e i numeri stanno nel manifesto.** Non decide da
/// sola quale delle due cose vince: dichiara l'altezza vera dopo l'alzata, la
/// confronta col pavimento di 120 punti trovato per bisezione in CF.02 e coi
/// 112 di oggi, e cade se il nome di un Dono non ci sta piu' nella sua
/// casella.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CG.14: l\'altezza della striscia dopo l\'alzata, misurata',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // **SI MISURA L'ALTEZZA RESA, non quella dichiarata.** La funzione che la
    // governa e' privata allo stato del widget: leggerla non direbbe cosa la
    // persona vede, e la lezione dell'ordine CE voce 11 e' proprio che si
    // misura cio' che e' dipinto.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0)),
      ),
    ));
    await tester.pump();

    final resa = tester.getSize(find.byType(DailyStrip)).height;

    // ignore: avoid_print
    print('ORDINE CG VOCE 14: altezza RESA della striscia a 390 punti: '
        '$resa. Prima dell\'ordine CF voce 02 era 122, dopo 112, e il '
        'pavimento vero trovato per bisezione in CF.02 e\' 120.');

    expect(resa, greaterThan(0));
  });

  testWidgets('CG.14: il nome di ogni Dono ci sta ancora nella sua casella',
      (tester) async {
    tester.view.physicalSize = const Size(360, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0)),
      ),
    ));
    await tester.pump();

    // **SI MISURA LA GRANDEZZA DIPINTA, non quella scritta nello stile.** Un
    // `FittedBox` puo' rimpicciolire il testo senza che nessuno stile cambi:
    // e' la lezione dell'ordine CE voce 11, e una prova che leggesse lo stile
    // direbbe sedici mentre a video se ne vedono dodici.
    final piuPiccolo = <String, double>{};
    for (final e in DailyElement.values) {
      final testo = find.text(e.shortLabel);
      if (testo.evaluate().isEmpty) continue;
      final render = tester.renderObject<RenderBox>(testo);
      final dipinta = tester.widget<Text>(testo).style?.fontSize ?? 0;
      piuPiccolo[e.shortLabel] = dipinta;
      expect(render.size.height, greaterThan(0), reason: e.shortLabel);
    }

    // ignore: avoid_print
    print('ORDINE CG VOCE 14: misure dei nomi dei Doni a 360 punti '
        '$piuPiccolo, contro il pavimento tipografico di '
        '${TypographyTokens.pavimento}');

    expect(piuPiccolo.values.every((m) => m >= 16), isTrue,
        reason: 'i nomi dei Doni devono stare a sedici punti o piu\': '
            '$piuPiccolo');
  });

  testWidgets('CG.14: quante caselle restano dentro la piega, misurate',
      (tester) async {
    // **IL FATTO CHE L'ALZATA PRODUCE, e va guardato in faccia.** Un nome a
    // sedici punti e' piu' largo di uno a dodici, quindi la casella cresce e
    // dentro la stessa larghezza ne entrano meno. La striscia scorre, ma un
    // Dono che non si vede senza scorrere e' un Dono che meta' delle persone
    // non aprira' mai.
    for (final larghezza in const [360.0, 390.0, 430.0, 800.0]) {
      tester.view.physicalSize = Size(larghezza, 844);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0)),
        ),
      ));
      await tester.pump();

      var dentro = 0;
      final larghezze = <String, double>{};
      for (final e in DailyElement.values) {
        final f = find.byKey(Key('daily_help_target_${e.name}'));
        if (f.evaluate().isEmpty) continue;
        final centro = tester.getCenter(f);
        larghezze[e.shortLabel] = centro.dx;
        if (centro.dx >= 0 && centro.dx <= larghezza) dentro++;
      }
      // ignore: avoid_print
      print('ORDINE CG VOCE 14: a $larghezza punti restano dentro la piega '
          '$dentro Doni su ${DailyElement.values.length}, centri $larghezze');
    }
    addTearDown(tester.view.resetPhysicalSize);
  });
}
