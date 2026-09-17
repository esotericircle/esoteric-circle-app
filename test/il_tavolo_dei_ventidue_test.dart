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
      final chiave = find.byKey(Key('arcano_alba_dorso_$i'));
      // **La misura vera della carta e' quella del suo riquadro**, che non
      // ruota con lei: da quando il ventaglio le inclina, il rettangolo che
      // il banco restituisce non e' piu' il loro ingombro.
      final misura = tester.getSize(chiave);
      expect(misura.width, greaterThanOrEqualTo(32),
          reason: 'il dorso $i e\' largo ${misura.width.toStringAsFixed(1)} '
              'punti: non si tocca con un dito');
      // E lo sbordo si guarda sui quattro angoli, che con la rotazione sono
      // gli unici punti che stanno davvero dove sembrano.
      final angoli = [
        tester.getTopLeft(chiave),
        tester.getTopRight(chiave),
        tester.getBottomLeft(chiave),
        tester.getBottomRight(chiave),
      ];
      for (final a in angoli) {
        expect(a.dx, greaterThanOrEqualTo(-1),
            reason: 'il dorso $i sborda a sinistra, fino a ${a.dx}');
        expect(a.dx, lessThanOrEqualTo(361),
            reason: 'il dorso $i sborda a destra, fino a ${a.dx}');
      }
      expect(find.byKey(Key('arcano_alba_carta_$i')), findsOneWidget,
          reason: 'il dorso $i non si puo\' toccare');
    }
    print('ORDINE DU voce 02: a 360 punti le carte sono larghe '
        '${tester.getSize(find.byKey(const Key('arcano_alba_dorso_0'))).width.toStringAsFixed(1)} '
        'punti, su ${TavoloDeiVentidue.righeDi(22, 360).length} righe');
  });

  /// Gli indici delle carte, riga per riga, come il tavolo le dispone.
  List<List<int>> righeDelTavolo({double larghezza = 360}) {
    final quante = TavoloDeiVentidue.righeDi(22, larghezza);
    final righe = <List<int>>[];
    var scorso = 0;
    for (final n in quante) {
      righe.add([for (var j = 0; j < n; j++) scorso + j]);
      scorso += n;
    }
    return righe;
  }

  testWidgets('SOVRAPPOSTE, ma non nascoste: ognuna resta distinguibile',
      (tester) async {
    await monta(tester, ridotto: true);
    final rettangoli = pose(tester);
    // **Le righe non si riconoscono piu' dal centro verticale**, perche' da
    // quando sono archi ogni carta di una riga sta a una quota sua: si
    // prendono dalla stessa funzione che le dispone.
    var coppieSovrapposte = 0;
    for (final riga in righeDelTavolo()) {
      for (var k = 1; k < riga.length; k++) {
        final a = rettangoli[riga[k - 1]], b = rettangoli[riga[k]];
        final passo = b.center.dx - a.center.dx;
        final larga = (a.width + b.width) / 2;
        expect(passo, lessThan(larga),
            reason: 'le carte ${riga[k - 1]} e ${riga[k]} non si '
                'sovrappongono');
        expect(passo, greaterThan(larga * 0.4),
            reason: 'la carta ${riga[k]} copre troppo della vicina');
        coppieSovrapposte++;
      }
    }
    expect(coppieSovrapposte, greaterThanOrEqualTo(19),
        reason: 'coppie guardate $coppieSovrapposte: su un insieme vuoto '
            'questa prova sarebbe verde senza aver guardato niente');
  });

  testWidgets('OGNI RIGA E\' UN ARCO, e le carte dei bordi si inclinano',
      (tester) async {
    // **Richiesta del fondatore del 17 settembre 2026**: *"preferirei che le 3
    // file di carte siano disposte a ventaglio, formano una curva"*.
    //
    // Due grandezze, e nessuna delle due si vede leggendo il codice: la carta
    // centrale di ogni riga sta **piu' in alto** di quelle ai bordi, e le
    // carte dei bordi sono **inclinate**. L'inclinazione si misura dal
    // rettangolo che la carta occupa: una carta ruotata ne occupa uno piu'
    // largo di una dritta, a parita' di disegno.
    await monta(tester, ridotto: true);
    final rettangoli = pose(tester);
    var righeGuardate = 0;
    for (final riga in righeDelTavolo()) {
      final centrale = rettangoli[riga[riga.length ~/ 2]];
      final sinistra = rettangoli[riga.first];
      final destra = rettangoli[riga.last];
      expect(centrale.center.dy, lessThan(sinistra.center.dy - 3),
          reason: 'la carta centrale della riga non sta piu\' in alto del '
              'bordo sinistro: la riga e\' piatta');
      expect(centrale.center.dy, lessThan(destra.center.dy - 3),
          reason: 'la carta centrale della riga non sta piu\' in alto del '
              'bordo destro: la riga e\' piatta');
      // **L'inclinazione si legge dagli angoli, non dal rettangolo.** Il
      // rettangolo che il banco restituisce per una carta ruotata e'
      // costruito su due soli vertici, e per una figura girata non e' il suo
      // ingombro: misurato, dava la carta inclinata piu' STRETTA di quella
      // dritta. Due angoli in cima allo stesso lato dicono la pendenza vera.
      double pendenzaDi(int carta) {
        final chiave = find.byKey(Key('arcano_alba_dorso_$carta'));
        return tester.getTopRight(chiave).dy - tester.getTopLeft(chiave).dy;
      }

      final pendenzaSinistra = pendenzaDi(riga.first);
      final pendenzaCentro = pendenzaDi(riga[riga.length ~/ 2]);
      final pendenzaDestra = pendenzaDi(riga.last);
      expect(pendenzaCentro.abs(), lessThan(2),
          reason: 'la carta centrale della riga pende di $pendenzaCentro '
              'punti: al centro il ventaglio sta dritto');
      expect(pendenzaSinistra.abs(), greaterThan(4),
          reason: 'la carta di sinistra non e\' inclinata');
      expect(pendenzaDestra.abs(), greaterThan(4),
          reason: 'la carta di destra non e\' inclinata');
      expect(pendenzaSinistra * pendenzaDestra, lessThan(0),
          reason: 'i due bordi pendono dalla stessa parte: e\' una riga '
              'storta, non un ventaglio');
      righeGuardate++;
    }
    expect(righeGuardate, 3,
        reason: 'righe guardate $righeGuardate: a 360 punti sono tre');
    final alzata = rettangoli[0].center.dy - rettangoli[4].center.dy;
    print('ORDINE DU: l\'arco alza la carta centrale di '
        '${alzata.toStringAsFixed(1)} punti sopra il bordo della riga');
  });

  testWidgets('MISCHIA E TAGLIA SONO DUE BOLLE', (tester) async {
    // Richiesta del fondatore: *"Mischia e taglia all'interno di 2 bolle, come
    // pulsanti"*. Una bolla e' tonda: si misura che il pulsante sia quadrato
    // nel suo ingombro, cioe' un cerchio, e non una pillola larga e bassa.
    await monta(tester, ridotto: true);
    for (final chiave in ['arcano_alba_mischia', 'arcano_alba_taglia']) {
      final misura = tester.getSize(find.byKey(Key(chiave)));
      expect(misura.width, closeTo(misura.height, 1),
          reason: '$chiave misura ${misura.width} per ${misura.height}: '
              'non e\' una bolla');
      expect(misura.width, greaterThanOrEqualTo(84),
          reason: '$chiave e\' larga ${misura.width}: sotto gli 84 punti '
              'l\'etichetta non ci sta');
    }
    // E dentro la bolla ci sono ancora le parole, non solo un segno.
    expect(find.text('Mischia'), findsOneWidget);
    expect(find.text('Taglia'), findsOneWidget);
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
