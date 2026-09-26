import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/resonance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/resonance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// I NOMI NON SI SOVRAPPONGONO NELLA RISONANZA. Ordine BC voce 04.
///
/// **Il fatto del fondatore**: "nell onboarding, quando viene rivelato il
/// Maestro assegnato, vengono mostrati dei cerchi colorati sfumati, ma i nomi
/// si sovrappongono". Nello screenshot si legge MEDORA scritto sopra CALIGO.
///
/// **La causa era una riga sola**, e lo diceva a chiare lettere:
/// `softWrap: false` con `overflow: TextOverflow.visible` significa *esci
/// dalla tua colonna invece di adattarti*. Ogni Maestro vive in un `Expanded`,
/// cioe' in un terzo della larghezza; il vincitore porta la tipografia
/// cerimoniale, piu' grande delle altre due, e MEDORA a quella misura e' piu'
/// largo di un terzo dello schermo.
///
/// **PERCHE' QUESTA PROVA GUARDA I PIXEL E NON I RETTANGOLI.** E' la lezione
/// dell ordine BA voce 02, pagata quattro volte: un testo con
/// `overflow: visible` ha un rettangolo di layout **stretto quanto il
/// vincolo** e dipinge fuori da li'. Chiedere a `tester.getRect` quanto e'
/// largo quel nome avrebbe risposto "un terzo dello schermo" anche mentre
/// sbordava sul vicino, e la prova sarebbe stata verde sul difetto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Il caso che il fondatore ha in mano: tre percentuali vicine, e a vincere
  /// e' quello col nome piu' lungo.
  const risonanza = Resonance(
    scores: {
      Maestro.medora: 0.350,
      Maestro.caligo: 0.352,
      Maestro.aura: 0.298,
    },
    winner: Maestro.medora,
    reason: 'Il tuo cielo pende verso la voce di Medora.',
    deciding: 'il Sole',
  );

  Future<List<int>> dipingi(WidgetTester tester, double larghezza) async {
    tester.view.physicalSize = Size(larghezza, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF05030F),
        body: RepaintBoundary(
          key: const Key('la_risonanza'),
          child: MaestroScope(
            maestro: Maestro.medora,
            child: ResonanceScreen(
              resonance: risonanza,
              onContinue: () {},
            ),
          ),
        ),
      ),
    ));
    // Le aure pulsano: si ferma il tempo su un fotogramma qualunque, che per
    // i nomi non cambia niente.
    await tester.pump(const Duration(milliseconds: 120));
    late List<int> px;
    await tester.runAsync(() async {
      final ro = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('la_risonanza')));
      final im = await ro.toImage();
      final d = await im.toByteData(format: ui.ImageByteFormat.rawRgba);
      px = d!.buffer.asUint8List();
      im.dispose();
    });
    return px;
  }

  /// La fascia verticale in cui stanno i tre nomi, presa dal loro rettangolo.
  Rect fasciaDeiNomi(WidgetTester tester) {
    var alto = double.infinity, basso = -1.0;
    for (final m in Maestro.values) {
      final f = find.text(m.displayName);
      if (f.evaluate().isEmpty) continue;
      final r = tester.getRect(f);
      if (r.top < alto) alto = r.top;
      if (r.bottom > basso) basso = r.bottom;
    }
    return Rect.fromLTRB(0, alto, 0, basso);
  }

  testWidgets('BC.04: i tre nomi restano tre parole separate', (tester) async {
    const larghezza = 360.0;
    final px = await dipingi(tester, larghezza);
    final fascia = fasciaDeiNomi(tester);
    expect(fascia.bottom, greaterThan(0), reason: 'i nomi non si trovano');

    // **Colonna per colonna, quanto inchiostro c e nella fascia dei nomi.**
    // Un nome e' un gruppo di colonne accese; fra un nome e l altro devono
    // restare colonne spente. Se due nomi si toccano, i gruppi diventano due
    // invece di tre, e questo conto se ne accorge.
    final accese = List<bool>.filled(larghezza.toInt(), false);
    for (var x = 0; x < larghezza.toInt(); x++) {
      for (var y = fascia.top.floor(); y < fascia.bottom.ceil(); y++) {
        final i = (y * larghezza.toInt() + x) * 4;
        if (i + 3 >= px.length) continue;
        // **SI CERCANO LE LETTERE, NON LE AURE, e la differenza e' tutta
        // qui.** Le tre aure sono cerchi sfumati larghi piu' della loro
        // colonna e si accavallano **per disegno**: e' l'effetto che il
        // fondatore descrive, "cerchi colorati sfumati", e non e' un difetto.
        // La prima stesura di questa prova le contava come inchiostro e
        // dichiarava sporco il confine anche a nomi perfettamente separati.
        //
        // Una lettera e' chiara su tutti e tre i canali; il bordo di un'aura
        // e' saturo, cioe' alto su uno o due canali e basso sugli altri.
        if (px[i] > 150 && px[i + 1] > 150 && px[i + 2] > 120) {
          accese[x] = true;
          break;
        }
      }
    }
    // **I NOMI SONO TRE GRUPPI DI LETTERE, E FRA LORO CI DEVE ESSERE ARIA.**
    //
    // **Due stesure precedenti sono state buttate, e vale la pena dire
    // perche'.** La prima contava i gruppi di colonne accese e ne trovava
    // QUATTORDICI su tre nomi: fra una lettera e l'altra c'e' una colonna
    // spenta, quindi contava le lettere. La seconda guardava i due confini a
    // un terzo e due terzi dello schermo, e li dichiarava sporchi: **quei
    // confini non esistono**, perche' la schermata ha un margine esterno e le
    // colonne vere cominciano piu' dentro. Misurata la scena, CALIGO andava
    // da 238 a 332 dentro una colonna che va da 232 a 336, cioe' stava
    // benissimo a casa sua.
    //
    // Il metro giusto non ha bisogno di sapere dove cadono le colonne: si
    // uniscono le lettere vicine in parole, e le parole devono restare TRE.
    // Misurato sulla scena sana: i vuoti fra lettere valgono al massimo tre
    // punti, quelli fra un nome e l'altro dieci e venticinque.
    const ariaFraLettere = 7;
    final parole = <({int da, int a})>[];
    int? inizio;
    var spenteDiFila = 0;
    for (var x = 0; x < accese.length; x++) {
      if (accese[x]) {
        inizio ??= x;
        spenteDiFila = 0;
      } else if (inizio != null) {
        spenteDiFila++;
        if (spenteDiFila > ariaFraLettere) {
          parole.add((da: inizio, a: x - spenteDiFila));
          inizio = null;
          spenteDiFila = 0;
        }
      }
    }
    if (inizio != null) parole.add((da: inizio, a: accese.length - 1));

    // Quanta aria resta fra una parola e la vicina: e' il margine che separa
    // questa schermata dal difetto, e se domani si assottiglia si vede qui.
    final arie = <int>[];
    for (var i = 1; i < parole.length; i++) {
      arie.add(parole[i].da - parole[i - 1].a);
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 04: nella fascia dei nomi, da '
        '${fascia.top.round()} a ${fascia.bottom.round()}, le parole dipinte '
        'sono ${parole.length}, larghe '
        '${parole.map((p) => p.a - p.da).toList()}, e fra loro restano $arie '
        'punti d aria');
    expect(parole, hasLength(3),
        reason: 'le parole dipinte nella fascia dei nomi sono '
            '${parole.length} invece di tre: due nomi si sono toccati, ed e '
            'il fatto del fondatore');
    for (final a in arie) {
      expect(a, greaterThan(ariaFraLettere),
          reason: 'fra due nomi restano solo $a punti: si stanno avvicinando '
              'e al prossimo nome piu lungo si toccheranno');
    }
  });

  testWidgets('BC.04: e il nome non viene tagliato per farlo stare',
      (tester) async {
    // **LA CONTROPROVA.** Rimpicciolire e' giusto, troncare no: coi puntini
    // il vincitore diventerebbe "MEDO...", e il nome del proprio Maestro e'
    // l ultima cosa che si puo abbreviare in questa schermata. Se un giorno
    // qualcuno risolvesse la sovrapposizione con `TextOverflow.ellipsis`,
    // questa cade.
    await dipingi(tester, 300);
    for (final m in Maestro.values) {
      expect(find.text(m.displayName), findsOneWidget,
          reason: 'il nome di ${m.name} non si trova per intero: e stato '
              'troncato invece che rimpicciolito');
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 04: a 300 punti di larghezza i tre nomi si leggono '
        'ancora per intero');
  });
}
