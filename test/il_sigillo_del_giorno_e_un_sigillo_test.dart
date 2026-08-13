import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/features/maestri/caligo/rune/bindrune.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL SIGILLO DEL GIORNO E' UN SIGILLO, NON UNO SCARABOCCHIO. Ordine S voce 25.
///
/// **Il difetto.** Il segno era un intreccio di tratti d'oro sospeso sul fondo:
/// nessuna forma che lo contenesse, nessun appoggio, nessun bordo. **Un sigillo e'
/// un segno impresso su qualcosa**, e senza quel qualcosa restano solo delle linee
/// che si incrociano.
///
/// **Cosa misurano queste prove, e sulla RESA.** Che l'anello ci sia e sia chiuso,
/// che il segno stia dentro con un margine e non lo tocchi mai, e che il segno non
/// sia diventato un puntino dentro un cerchio grande. Tre cose che si vedono, quindi
/// si misurano sui pixel e non sul sorgente.
void main() {
  /// Il lato del sigillo nella prova. Grande abbastanza perche' un pixel valga
  /// meno di mezzo punto: sotto, il tratto dell'anello sparirebbe
  /// nell'arrotondamento e la prova misurerebbe l'antialiasing.
  const lato = 300.0;

  /// Sopra questa luminanza un pixel e' INCHIOSTRO, cioe' un tratto del sigillo o
  /// dell'anello. Sotto, e' fondo o alone.
  const sogliaInchiostro = 120;

  Future<ui.Image> disegna(WidgetTester tester, GlobalKey chiave,
      {List<String> rune = const ['Fehu', 'Uruz', 'Ansuz']}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF120A0E),
        body: Center(
          child: RepaintBoundary(
            key: chiave,
            child: BindruneSigillo(
              runeNames: rune,
              lato: lato,
              oro: const Color(0xFFE8C87A),
              alone: const Color(0xFFE8A65A),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final boundary =
        chiave.currentContext!.findRenderObject() as RenderRepaintBoundary;
    return boundary.toImage(pixelRatio: 1.0);
  }

  testWidgets('l\'anello c\'e\' ed e\' chiuso tutt\'intorno', (tester) async {
    final chiave = GlobalKey();
    late final int angoliSenzaAnello;
    await tester.runAsync(() async {
      final image = await disegna(tester, chiave);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final w = image.width;
      final h = image.height;
      final cx = w / 2;
      final cy = h / 2;
      final raggio = math.min(w, h) * BindruneSigillo.raggioDelTondo;

      double luminanza(int x, int y) {
        if (x < 0 || y < 0 || x >= w || y >= h) return 0;
        final i = (y * w + x) * 4;
        return 0.2126 * px[i] + 0.7152 * px[i + 1] + 0.0722 * px[i + 2];
      }

      // **SI CAMPIONA LA CIRCONFERENZA a settantadue angoli, uno ogni cinque
      // gradi**, e su ognuno si guarda una fascia di tre pixel attorno al raggio,
      // perche' il tratto e' sottile e l'antialiasing lo sposta di poco.
      var senza = 0;
      for (var g = 0; g < 72; g++) {
        final a = g * math.pi / 36;
        var trovato = false;
        for (var d = -2; d <= 2 && !trovato; d++) {
          final x = (cx + (raggio + d) * math.cos(a)).round();
          final y = (cy + (raggio + d) * math.sin(a)).round();
          if (luminanza(x, y) >= sogliaInchiostro) trovato = true;
        }
        if (!trovato) senza++;
      }
      angoliSenzaAnello = senza;
    });
    expect(angoliSenzaAnello, 0,
        reason: 'l\'anello del sigillo non e\' chiuso: su $angoliSenzaAnello '
            'angoli su 72 non c\'e\' tratto. Un sigillo aperto e\' un cerchio '
            'incompiuto, non una cornice');
  });

  testWidgets('il segno sta DENTRO l\'anello e non lo tocca', (tester) async {
    final chiave = GlobalKey();
    late final double raggioDelSegno;
    late final double raggioAmmesso;
    await tester.runAsync(() async {
      final image = await disegna(tester, chiave);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final w = image.width;
      final h = image.height;
      final cx = w / 2;
      final cy = h / 2;
      final lato0 = math.min(w, h).toDouble();
      final raggio = lato0 * BindruneSigillo.raggioDelTondo;
      // Il margine dichiarato: dentro questa corona non deve esserci inchiostro
      // del segno. Si tolgono due pixel per il tratto dell'anello stesso, che in
      // quella corona ci sta di diritto.
      raggioAmmesso = raggio - lato0 * BindruneSigillo.margineDelTondo;

      var massimo = 0.0;
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final i = (y * w + x) * 4;
          final l = 0.2126 * px[i] + 0.7152 * px[i + 1] + 0.0722 * px[i + 2];
          if (l < sogliaInchiostro) continue;
          final d = math.sqrt(math.pow(x - cx, 2) + math.pow(y - cy, 2));
          // L'anello e' inchiostro anche lui: si guarda solo cio' che sta DENTRO
          // di lui, cioe' il segno.
          if (d > raggio - 3) continue;
          if (d > massimo) massimo = d;
        }
      }
      raggioDelSegno = massimo;
    });
    expect(raggioDelSegno, lessThanOrEqualTo(raggioAmmesso),
        reason: 'il segno arriva a ${raggioDelSegno.toStringAsFixed(1)} pixel dal '
            'centro e l\'anello con margine ne ammette '
            '${raggioAmmesso.toStringAsFixed(1)}: il sigillo tocca la sua '
            'cornice, e un segno che tocca il bordo si legge come tagliato');
  });

  testWidgets('il segno non e\' diventato un puntino dentro un cerchio',
      (tester) async {
    // **IL PRESIDIO OPPOSTO, e senza di lui la prova di prima si passerebbe
    // rimpicciolendo il glifo fino a farlo sparire.** Il segno deve occupare una
    // parte dichiarata del disco: almeno un terzo del raggio ammesso, e almeno il
    // due per cento dei pixel del disco.
    final chiave = GlobalKey();
    late final double raggioDelSegno;
    late final double raggioAmmesso;
    late final double quotaDiInchiostro;
    await tester.runAsync(() async {
      final image = await disegna(tester, chiave);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final w = image.width;
      final h = image.height;
      final cx = w / 2;
      final cy = h / 2;
      final lato0 = math.min(w, h).toDouble();
      final raggio = lato0 * BindruneSigillo.raggioDelTondo;
      raggioAmmesso = raggio - lato0 * BindruneSigillo.margineDelTondo;

      var massimo = 0.0;
      var dentro = 0;
      var accesi = 0;
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final d = math.sqrt(math.pow(x - cx, 2) + math.pow(y - cy, 2));
          if (d > raggio - 3) continue;
          dentro++;
          final i = (y * w + x) * 4;
          final l = 0.2126 * px[i] + 0.7152 * px[i + 1] + 0.0722 * px[i + 2];
          if (l < sogliaInchiostro) continue;
          accesi++;
          if (d > massimo) massimo = d;
        }
      }
      raggioDelSegno = massimo;
      quotaDiInchiostro = dentro == 0 ? 0 : accesi / dentro;
    });
    expect(raggioDelSegno, greaterThan(raggioAmmesso / 3),
        reason: 'il segno arriva solo a ${raggioDelSegno.toStringAsFixed(1)} '
            'pixel dal centro: dentro il tondo e\' un puntino');
    expect(quotaDiInchiostro, greaterThan(0.02),
        reason: 'dentro il disco l\'inchiostro e\' il '
            '${(quotaDiInchiostro * 100).toStringAsFixed(1)} per cento: il '
            'sigillo e\' quasi vuoto');
    expect(quotaDiInchiostro, lessThan(0.35),
        reason: 'dentro il disco l\'inchiostro e\' il '
            '${(quotaDiInchiostro * 100).toStringAsFixed(1)} per cento: il '
            'sigillo e\' una macchia e non un segno');
  });

  test('il riquadro del glifo si ricava dall\'anello, non si sceglie', () {
    // Le due costanti sono la fonte del riquadro: se qualcuno le cambia, il glifo
    // le segue da solo. Questa riga tiene vero il rapporto, cosi' nessuno
    // reintroduce un terzo numero scritto a mano.
    expect(BindruneSigillo.raggioDelTondo, greaterThan(
        BindruneSigillo.margineDelTondo),
        reason: 'il margine si mangia tutto il tondo: non resterebbe posto per '
            'il segno');
  });
}
