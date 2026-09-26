import 'package:esoteric_circle/core/rituals/tempi_del_respiro.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attorno_al_soffio.dart';

/// LA SCHEDA NON SALE MAI SUL RESPIRO, SU NESSUNO SCHERMO.
/// Ordine DR voce 11, 16 settembre 2026.
///
/// **Il fatto, e non e' nuovo: e' la seconda volta.** Il fondatore ha rivisto
/// il pulsante *"Tocca per cominciare"* tagliato a meta' dalla scheda del
/// responso. Lo stesso difetto era stato curato dall'ordine 2164 voce 8, con
/// un rapporto fisso fra le due zone della colonna, sei contro tre, e la cura
/// era stata misurata: venticinque virgola uno punti coperti prima, zero dopo.
///
/// **Perche' la guardia di allora non l'ha ripreso, ed e' la cosa da
/// imparare.** `il_pulsante_del_soffio_non_e_coperto_test.dart` misura **una
/// geometria sola**: 360 per 797 punti, barre 40 e 24, scala del testo uno.
/// Li' e' verde, e lo e' ancora oggi. Ma il margine che lascia e' di **quattro
/// punti**: il pulsante finisce a 543,3 e la scheda comincia a 547,3. Un
/// rapporto fisso fra due zone non tiene un margine, lo lascia al caso: basta
/// uno schermo piu' basso, una barra piu' alta o un carattere piu' grande e i
/// quattro punti se li mangia qualcuno.
///
/// **Cosa misura questa, e perche' e' un'altra domanda.** Non un telefono: una
/// **griglia**. Altezze diverse, barre diverse, scale del testo diverse. La
/// grandezza misurata e' la **distanza fra il fondo della guida del respiro e
/// il tetto della scheda**, e si pretende che non sia mai negativa. Una
/// geometria sola dice com'e' andata su un telefono; una griglia dice se la
/// forma regge.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Le altezze: dallo schermo basso che i telefoni piccoli hanno davvero,
  /// fino a uno alto. La larghezza resta quella del Realme del collaudo.
  const altezze = <double>[640, 700, 750, 797, 850, 900];

  /// Le barre di sistema: niente barre, il caso del Realme, e un telefono con
  /// la barra di navigazione a gesti alta.
  const barre = <EdgeInsets>[
    EdgeInsets.zero,
    EdgeInsets.only(top: 40, bottom: 24),
    EdgeInsets.only(top: 48, bottom: 48),
  ];

  /// Le scale del testo: quella di chi sviluppa e quella massima che il
  /// corredo gia' prova, cioe' quella che una parte dei lettori imposta
  /// davvero.
  const scale = <double>[1.0, 1.3];

  Future<void> monta(
    WidgetTester tester, {
    required double altezza,
    required EdgeInsets rientri,
    required double scala,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final finestra = Size(360, altezza);
    tester.view.physicalSize = finestra;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(attornoAlSoffio(
      BreathDestinyScreen(now: DateTime(2026, 8, 7, 10, 30)),
      finestra: finestra,
      rientri: rientri,
      scala: scala,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('LA GUIDA DEL RESPIRO E LA SCHEDA NON SI TOCCANO MAI',
      (tester) async {
    final guasti = <String>[];
    var misurate = 0;
    var margineMinimo = double.infinity;
    String doveIlMinimo = '';

    for (final altezza in altezze) {
      for (final rientri in barre) {
        for (final scala in scale) {
          await monta(tester,
              altezza: altezza, rientri: rientri, scala: scala);
          final guida = find.byKey(const Key('guida_respiro'));
          final scheda = find.byKey(const Key('ritual_content'));
          if (guida.evaluate().isEmpty || scheda.evaluate().isEmpty) continue;
          misurate++;
          final rGuida = tester.getRect(guida);
          final rScheda = tester.getRect(scheda);
          final margine = rScheda.top - rGuida.bottom;
          final dove = 'altezza $altezza, barre ${rientri.top.toInt()}'
              '/${rientri.bottom.toInt()}, scala $scala';
          if (margine < margineMinimo) {
            margineMinimo = margine;
            doveIlMinimo = dove;
          }
          if (margine < 0) {
            guasti.add('$dove: la scheda sale '
                '${(-margine).toStringAsFixed(1)} punti sopra il respiro '
                '(guida fino a ${rGuida.bottom.toStringAsFixed(1)}, scheda '
                'da ${rScheda.top.toStringAsFixed(1)})');
          }
        }
      }
    }

    // **IL CARDINALE MINIMO.** Se il rito del giorno non porta un respiro
    // contato, o la scheda non compare, questa prova non misura niente e
    // sarebbe verde senza aver guardato: qui si dichiara quante geometrie si
    // aspetta di aver misurato.
    expect(misurate, greaterThanOrEqualTo(24),
        reason: 'misurate solo $misurate geometrie su '
            '${altezze.length * barre.length * scale.length}: questa prova '
            'stava per dire il vero su niente');
    // ignore: avoid_print
    print('SOFFIO, GRIGLIA: $misurate geometrie, margine minimo '
        '${margineMinimo.toStringAsFixed(1)} punti a $doveIlMinimo');
    expect(guasti, isEmpty,
        reason: 'la scheda del responso sale sopra la guida del respiro in '
            '${guasti.length} geometrie su $misurate:\n  '
            '${guasti.join("\n  ")}');
  });

  testWidgets('IL PULSANTE SI PREME PER INTERO SU OGNI SCHERMO',
      (tester) async {
    // **Non basta che i rettangoli non si tocchino**: il pulsante deve anche
    // stare dentro lo schermo e ricevere il dito al proprio centro. Un
    // pulsante spinto sotto il bordo e' tagliato uguale, solo da un altro
    // bordo, ed e' esattamente cio' che una cura fatta di spazio potrebbe
    // produrre curando la sovrapposizione.
    final guasti = <String>[];
    var misurate = 0;
    for (final altezza in altezze) {
      for (final rientri in barre) {
        for (final scala in scale) {
          await monta(tester,
              altezza: altezza, rientri: rientri, scala: scala);
          final pulsante = find.byKey(const Key('respiro_tocca'));
          if (pulsante.evaluate().isEmpty) continue;
          misurate++;
          final r = tester.getRect(pulsante);
          final dove = 'altezza $altezza, barre ${rientri.top.toInt()}'
              '/${rientri.bottom.toInt()}, scala $scala';
          final fondo = altezza - rientri.bottom;
          if (r.bottom > fondo + 0.1) {
            guasti.add('$dove: il pulsante finisce a '
                '${r.bottom.toStringAsFixed(1)} e lo schermo utile finisce a '
                '${fondo.toStringAsFixed(1)}');
          }
          if (r.top < rientri.top - 0.1) {
            guasti.add('$dove: il pulsante comincia a '
                '${r.top.toStringAsFixed(1)}, sotto la barra di stato');
          }
        }
      }
    }
    expect(misurate, greaterThanOrEqualTo(24),
        reason: 'misurate solo $misurate geometrie');
    expect(guasti, isEmpty,
        reason: 'il pulsante esce dallo schermo utile in ${guasti.length} '
            'geometrie su $misurate:\n  ${guasti.join("\n  ")}');
  });

  testWidgets('e il conto parte davvero, col dito al centro', (tester) async {
    // La geometria piu' stretta della griglia: schermo basso, barre alte,
    // testo grande. Se il gesto arriva qui, arriva dappertutto.
    await monta(tester,
        altezza: 640,
        rientri: const EdgeInsets.only(top: 48, bottom: 48),
        scala: 1.3);
    final pulsante = find.byKey(const Key('respiro_tocca'));
    if (pulsante.evaluate().isEmpty) {
      markTestSkipped('Il rito di questo giorno non porta un respiro '
          'contato: non c\'e\' nessun pulsante da toccare.');
      return;
    }
    await tester.tapAt(tester.getCenter(pulsante));
    await tester.pump();
    expect(find.text('3'), findsOneWidget,
        reason: 'sullo schermo piu' ' stretto il tocco al centro non fa '
            'partire il conto: qualcosa sta davanti e se lo prende');
    await tester.pump(ParoleDelRespiro.durataDelConto);
    await tester.pump(const Duration(milliseconds: 200));
  });
}
