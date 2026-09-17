// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/rituals/tavolo_dei_ventidue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL TAVOLO DEI VENTIDUE.** Ordine DU voci 02 e 05, seconda stesura del
/// 17 settembre 2026, dopo che il fondatore ha respinto il ventaglio.
///
/// Le grandezze misurate sono quattro, e sono quelle che la richiesta nomina:
///
/// 1. **si vedono tutti e ventidue**, e ognuno e' grande abbastanza da essere
///    toccato con un dito, su uno schermo da 360 punti;
/// 2. **sono leggermente sovrapposti**, cioe' ogni carta copre un pezzo della
///    vicina e ne lascia scoperto abbastanza da distinguerla;
/// 3. **entrano e fluttuano**: le pose dell'ingresso non sono quelle di
///    riposo, e a tavolo posato le carte continuano a muoversi ognuna per
///    conto suo;
/// 4. **mischia e taglia muovono le figure, non la sorte**.
void main() {
  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  /// Monta il solo tavolo, alla larghezza data, e restituisce il comando
  /// della rivelazione per chi vuole girare la carta.
  Future<AnimationController> monta(WidgetTester tester,
      {double larghezza = 360,
      bool ridotto = false,
      int? scelta,
      void Function(int)? onScegli}) async {
    tester.view.physicalSize = Size(larghezza, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final rivelazione = AnimationController(
        vsync: tester, duration: const Duration(milliseconds: 1400));
    addTearDown(rivelazione.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: TavoloDeiVentidue(
            palette: palette,
            onScegli: onScegli ?? (_) {},
            rivelazione: rivelazione,
            scelta: scelta,
            ridotto: ridotto,
            faccia: (context) => const ColoredBox(color: Colors.amber),
          ),
        ),
      ),
    ));
    await tester.pump();
    return rivelazione;
  }

  List<Rect> pose(WidgetTester tester) => [
        for (var i = 0; i < 22; i++)
          tester.getRect(find.byKey(Key('arcano_alba_dorso_$i'))),
      ];

  test('LE RIGHE VENGONO DAL CONTO, non da un numero scritto a mano', () {
    // Su 360 punti undici carte per riga darebbero a ogni dorso meno di
    // trentadue punti: si sceglie tre righe. Sopra i 420 due righe bastano.
    expect(TavoloDeiVentidue.righeDi(22, 360), [8, 7, 7]);
    expect(TavoloDeiVentidue.righeDi(22, 419.9), [8, 7, 7]);
    expect(TavoloDeiVentidue.righeDi(22, 420), [11, 11]);
    expect(TavoloDeiVentidue.righeDi(22, 900), [11, 11]);
    for (final larghezza in [320.0, 360.0, 420.0, 600.0, 1024.0]) {
      final righe = TavoloDeiVentidue.righeDi(22, larghezza);
      expect(righe.reduce((a, b) => a + b), 22,
          reason: 'a $larghezza punti le righe portano '
              '${righe.reduce((a, b) => a + b)} carte invece di ventidue');
    }
  });

  testWidgets('TUTTI E VENTIDUE SI VEDONO E SI POSSONO TOCCARE, a 360 punti',
      (tester) async {
    await monta(tester, ridotto: true);
    final rettangoli = pose(tester);
    expect(rettangoli, hasLength(22));
    for (var i = 0; i < 22; i++) {
      final r = rettangoli[i];
      expect(r.width, greaterThanOrEqualTo(32),
          reason: 'il dorso $i e\' largo ${r.width.toStringAsFixed(1)} punti: '
              'non si tocca con un dito');
      expect(r.left, greaterThanOrEqualTo(-1),
          reason: 'il dorso $i sborda a sinistra');
      expect(r.right, lessThanOrEqualTo(361),
          reason: 'il dorso $i sborda a destra');
      expect(find.byKey(Key('arcano_alba_carta_$i')), findsOneWidget,
          reason: 'il dorso $i non si puo\' toccare');
    }
    print('ORDINE DU voce 02: a 360 punti le carte sono larghe '
        '${rettangoli.first.width.toStringAsFixed(1)} punti, su '
        '${TavoloDeiVentidue.righeDi(22, 360).length} righe');
  });

  testWidgets('SOVRAPPOSTE, ma non nascoste: ognuna resta distinguibile',
      (tester) async {
    await monta(tester, ridotto: true);
    final rettangoli = pose(tester);
    final larga = rettangoli.first.width;
    var coppieSovrapposte = 0;
    for (var i = 1; i < 22; i++) {
      final a = rettangoli[i - 1], b = rettangoli[i];
      // Due carte sulla stessa riga hanno lo stesso centro verticale.
      if ((a.center.dy - b.center.dy).abs() > 1) continue;
      final passo = b.left - a.left;
      expect(passo, lessThan(larga),
          reason: 'le carte $i e ${i - 1} non si sovrappongono');
      expect(passo, greaterThan(larga * 0.5),
          reason: 'la carta $i copre piu\' di meta\' della vicina');
      coppieSovrapposte++;
    }
    expect(coppieSovrapposte, greaterThanOrEqualTo(19),
        reason: 'coppie guardate $coppieSovrapposte: su un insieme vuoto '
            'questa prova sarebbe verde senza aver guardato niente');
  });

  testWidgets('ENTRANO E FLUTTUANO: le pose dell\'ingresso non sono il riposo',
      (tester) async {
    // **La scena non e' una foto.** Con Riduci Movimento il tavolo si posa
    // fermo, e quella e' la posa di riposo: durante l'ingresso le carte
    // stanno altrove, e a tavolo posato continuano a respirare.
    await monta(tester, ridotto: true);
    final riposo = pose(tester);
    await tester.pumpWidget(const SizedBox());

    await monta(tester);
    await tester.pump(const Duration(milliseconds: 250));
    final entrando = pose(tester);
    var lontane = 0;
    for (var i = 0; i < 22; i++) {
      if ((entrando[i].center - riposo[i].center).distance > 8) lontane++;
    }
    expect(lontane, greaterThan(15),
        reason: 'a un quarto di secondo dall\'ingresso soltanto $lontane '
            'carte su ventidue sono lontane dalla loro posa: la spirale non '
            'si vede');

    // A tavolo posato il respiro continua, e ognuna ha la sua fase: le carte
    // non si muovono tutte insieme come un blocco.
    await tester.pump(const Duration(milliseconds: 1600));
    final prima = pose(tester);
    await tester.pump(const Duration(milliseconds: 900));
    final poi = pose(tester);
    final scarti = [
      for (var i = 0; i < 22; i++) (poi[i].center - prima[i].center).distance,
    ];
    expect(scarti.where((s) => s > 0.5).length, greaterThan(10),
        reason: 'il tavolo posato e\' fermo: $scarti');
    expect(scarti.toSet(), hasLength(greaterThan(10)),
        reason: 'le carte si muovono tutte dello stesso tanto: e\' un blocco '
            'che trema, non ventidue carte che respirano');
  });

  testWidgets('CON RIDUCI MOVIMENTO il tavolo si posa fermo', (tester) async {
    await monta(tester, ridotto: true);
    final prima = pose(tester);
    await tester.pump(const Duration(seconds: 3));
    expect(pose(tester), prima,
        reason: 'con Riduci Movimento le carte si muovono lo stesso');
  });

  testWidgets('MISCHIA E TAGLIA muovono le figure, non la sorte',
      (tester) async {
    // **La cosa piu' importante di questa prova.** I due gesti restano perche'
    // sono quelli che si fanno con un mazzo vero, ma la carta si estrae nel
    // momento del tocco: qui si misura che dopo il mescolamento il tocco sul
    // dorso numero tre chiami ancora il numero tre, cioe' che i gesti non
    // tocchino cio' che viene consegnato.
    final scelti = <int>[];
    await monta(tester, onScegli: scelti.add);
    await tester.pump(const Duration(milliseconds: 1600));
    final prima = pose(tester);

    // **Il primo fotogramma dopo il tocco e' ancora fermo**: il comando parte
    // con la frazione a zero, e chi misura li' misura il tavolo immobile.
    // Visto con una sonda, non dedotto.
    await tester.tap(find.byKey(const Key('arcano_alba_mischia')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
    final durante = pose(tester);
    var mosse = 0;
    for (var i = 0; i < 22; i++) {
      if ((durante[i].center - prima[i].center).distance > 12) mosse++;
    }
    expect(mosse, greaterThan(15),
        reason: 'Mischia ha mosso soltanto $mosse carte su ventidue');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('arcano_alba_taglia')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('arcano_alba_carta_3')));
    await tester.pump();
    expect(scelti, [3],
        reason: 'dopo mischia e taglia il tocco sul dorso tre ha chiamato '
            '$scelti: i gesti stanno cambiando cio\' che si consegna');
  });

  testWidgets('LA SCIA DI STELLINE E\' IN SCENA', (tester) async {
    // Voce 05, con le parole del fondatore: *"crea animazioni originali con
    // stelline e scia di stelline che seguono la carta selezionata"*.
    final rivelazione = await monta(tester);
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byType(CustomPaint), findsWidgets);
    await tester.pumpWidget(const SizedBox());

    await monta(tester, scelta: 5);
    rivelazione.value = 0.4;
    await tester.pump();
    final dipinti = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .where((p) => p.painter != null)
        .length;
    expect(dipinti, greaterThan(0),
        reason: 'mentre la carta sale non c\'e\' nessuna scia dipinta');
  });
}
