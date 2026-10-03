// ignore_for_file: avoid_print
import 'dart:math' as math;

import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/horoscope/il_periodo_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE BARRE E LA GRIGLIA SI LEGGONO.** Ordine EU voci 09 e 11, 1 ottobre
/// 2026.
///
/// Il fondatore, sulla Settimana: *"le barre [...] sembrano tutte uguali,
/// dovrebbe cambiare anche l'altezza e magari inserire una percentuale [...]
/// da giallo opaco a rosso fuoco per il giorno migliore"*; sul Mese: *"lo
/// stesso problema dell'infografica poco chiara e molto simile tra loro"*.
///
/// Si misura: il contrasto di ogni gradino della scala sul fondo delle
/// schede del periodo con le quattro palette (almeno 3) e del numero scritto
/// sopra (almeno 4,5); nella Settimana l'altezza di ogni barra in proporzione
/// al livello, il colore del suo gradino, la percentuale sopra la migliore;
/// nel Mese una casella per ognuno dei trenta giorni col colore del suo
/// gradino e la percentuale sul migliore. Tutto a 360 punti, al carattere
/// normale e al massimo (2,0), senza un pixel che trabocca.
void main() {
  double canale(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luce(Color c) =>
      0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);
  double contrasto(Color a, Color b) {
    final l1 = luce(a), l2 = luce(b);
    return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
  }

  test('ogni gradino si legge sul fondo delle schede, e il numero sopra', () {
    final palette = [
      MaestroPalette.medora,
      MaestroPalette.aura,
      MaestroPalette.caligo,
      MaestroPalette.neutral,
    ];
    var coppie = 0;
    var peggiore = double.infinity;
    final sotto = <String>[];
    for (final p in palette) {
      // Il fondo del riquadro del periodo: la superficie all'85% sul fondo
      // della pagina.
      final fondo = Color.alphaBlend(
          p.surfaceElevated.withValues(alpha: 0.85), p.deepest);
      for (var l = 1; l <= 5; l++) {
        coppie++;
        final c = contrasto(ColorTokens.delLivello(l), fondo);
        peggiore = math.min(peggiore, c);
        if (c < 3) sotto.add('gradino $l sul fondo: ${c.toStringAsFixed(2)}');
        final n = contrasto(
            ColorTokens.inchiostroSulLivello, ColorTokens.delLivello(l));
        if (n < 4.5) {
          sotto.add('numero sul gradino $l: ${n.toStringAsFixed(2)}');
        }
      }
    }
    cardinaleMinimo(coppie, 20, cosa: 'gradini misurati sulle palette');
    print('ORDINE EU VOCI 09 E 11: contrasto peggiore di un gradino sul fondo '
        '${peggiore.toStringAsFixed(2)} su $coppie');
    expect(sotto, isEmpty, reason: sotto.join('\n'));
    // Cinque gradini diversi, dal giallo al rosso: la tinta scende.
    const scala = ColorTokens.scalaDelLivello;
    expect(scala.toSet().length, 5);
    for (var i = 1; i < scala.length; i++) {
      expect(HSVColor.fromColor(scala[i]).hue,
          lessThan(HSVColor.fromColor(scala[i - 1]).hue),
          reason: 'il gradino ${i + 1} non va verso il rosso');
    }
  });

  DominioDelPeriodo dominio(DateTime inizio, List<int> livelli) {
    final giorni = [
      for (var i = 0; i < livelli.length; i++)
        GiornoDelPeriodo(
            giorno: DateTime(inizio.year, inizio.month, inizio.day + i),
            livello: livelli[i],
            motivo: ''),
    ];
    var migliore = giorni.first;
    for (final g in giorni) {
      if (g.livello > migliore.livello) migliore = g;
    }
    return DominioDelPeriodo(
        dominio: HoroscopeDomain.amore,
        giorni: giorni,
        migliore: migliore,
        momentoChiave: '',
        voce: ITestiEu.voce(TradizioneEu.occidentale, PeriodoEu.settimana,
            HoroscopeDomain.amore, FasciaEu.equilibrio, 0));
  }

  Future<void> monta(WidgetTester t, Widget w, double scala) async {
    t.view.physicalSize = const Size(360, 797);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
            size: const Size(360, 797),
            textScaler: TextScaler.linear(scala),
            disableAnimations: true),
        child: Scaffold(
          body: Padding(
            // Il riquadro del periodo: 16 di margine e 16 di imbottitura.
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(child: w),
          ),
        ),
      ),
    ));
    await t.pump();
  }

  for (final scala in const [1.0, 2.0]) {
    testWidgets('le barre della Settimana alla scala $scala', (t) async {
      final livelli = [2, 3, 4, 5, 3, 2, 4];
      final d = dominio(DateTime(2026, 10, 1), livelli);
      await monta(
          t,
          LeBarreDellaSettimana(dominio: d, palette: MaestroPalette.medora),
          scala);
      expect(t.takeException(), isNull);
      const piena = LeBarreDellaSettimana.altezzaPiena;
      for (var i = 0; i < livelli.length; i++) {
        final barra = find.byKey(Key('oroscopo_periodo_barra_amore_${1 + i}'));
        final h = t.getSize(barra).height;
        expect(h, closeTo(piena * livelli[i] / 5, 0.5),
            reason: 'la barra del giorno ${i + 1} non e\' in proporzione al '
                'livello ${livelli[i]}: alta $h');
        final colore =
            ((t.widget<Container>(barra).decoration as BoxDecoration).color)!;
        expect(colore, ColorTokens.delLivello(livelli[i]),
            reason: 'la barra del giorno ${i + 1} non ha il suo gradino');
      }
      // La percentuale sopra la migliore, il 4 ottobre, livello 5.
      final perc = find.byKey(const Key('oroscopo_periodo_percentuale_amore'));
      expect(perc, findsOneWidget);
      expect(t.widget<Text>(perc).data, '100%');
      final sopra = t.getRect(perc);
      final barra =
          t.getRect(find.byKey(const Key('oroscopo_periodo_barra_amore_4')));
      expect(sopra.bottom, lessThanOrEqualTo(barra.top + 0.5),
          reason: 'la percentuale non sta sopra la barra migliore');
      expect((sopra.center.dx - barra.center.dx).abs(), lessThan(1.0));
    });

    testWidgets('il Mese a griglia alla scala $scala', (t) async {
      // Trenta giorni da giovedi' 1 ottobre: una casella per giorno.
      final livelli = [
        for (var i = 0; i < 30; i++) 2 + (i * 7 % 4),
      ];
      livelli[17] = 5;
      for (var i = 0; i < 30; i++) {
        if (i != 17 && livelli[i] == 5) livelli[i] = 4;
      }
      final d = dominio(DateTime(2026, 10, 1), livelli);
      await monta(t, IlCalendarioDelMese(dominio: d), scala);
      expect(t.takeException(), isNull);
      var caselle = 0;
      final mancanti = <String>[];
      for (final g in d.giorni) {
        final f = find.byKey(Key('oroscopo_periodo_casella_amore_'
            '${g.giorno.month}_${g.giorno.day}'));
        if (f.evaluate().isEmpty) {
          mancanti.add(LaSettimanaDelCielo.data(g.giorno));
          continue;
        }
        caselle++;
        final colore = ((t
                .widget<Container>(find
                    .descendant(of: f, matching: find.byType(Container))
                    .first)
                .decoration as BoxDecoration)
            .color)!;
        expect(colore, ColorTokens.delLivello(g.livello),
            reason: '${LaSettimanaDelCielo.data(g.giorno)} senza il suo '
                'gradino');
        expect(find.descendant(of: f, matching: find.text('${g.giorno.day}')),
            findsOneWidget,
            reason: 'la casella di ${LaSettimanaDelCielo.data(g.giorno)} '
                'non porta il numero del giorno');
      }
      cardinaleMinimo(caselle, 30, cosa: 'caselle del mese');
      expect(mancanti, isEmpty, reason: 'giorni senza casella: $mancanti');
      // La prima casella sta sotto il giovedi': quattro colonne vuote prima.
      final primo = t.getRect(
          find.byKey(const Key('oroscopo_periodo_casella_amore_10_1')));
      final lunedi = t.getRect(
          find.byKey(const Key('oroscopo_periodo_casella_amore_10_5')));
      expect(primo.top, lessThan(lunedi.top),
          reason: 'il 5 ottobre, lunedi\', non comincia la seconda riga');
      final perc = find.byKey(const Key('oroscopo_periodo_percentuale_amore'));
      expect(perc, findsOneWidget);
      expect(t.widget<Text>(perc).data, '100%');
      expect(
          find.descendant(
              of: find.byKey(const Key('oroscopo_periodo_casella_amore_10_18')),
              matching: perc),
          findsOneWidget,
          reason: 'la percentuale non sta sul giorno migliore');
    });
  }
}
