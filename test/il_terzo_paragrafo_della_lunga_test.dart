// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/design_system/components/il_responso_interpretato.dart';
import 'package:esoteric_circle/design_system/components/riquadro_arancione.dart';
import 'package:esoteric_circle/design_system/components/riquadro_in_evidenza.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/horoscope/il_periodo_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **IL TERZO PARAGRAFO DELLA LUNGA IN UN RIQUADRO.** Il fondatore, 1
/// ottobre 2026: *"Per ogni risposta, quando c'è la profondità lunga il terzo
/// paragrafo inseriscilo in un riquadro, così da sembrare in evidenza e
/// staccare dalla monotonia del testo."*
///
/// **DALL'ORDINE GA I RIQUADRI SONO DUE, E NON STANNO PIU' SUL TERZO.** Il
/// fondatore, 19 ottobre 2026 alle 23:08: *"Per le risposte brevi 2
/// paragrafi di cui il secondo messo in evidenza in un riquadro e questo
/// riquadro deve intitolarsi "cosa fare adesso" [...] Per le risposte lunghe
/// aggiungi 2 paragrafi sempre con il primo in riquadro"*; 20 ottobre alle
/// 00:10: *"Il secondo riquadro della risposta lunga, quindi il quarto
/// paragrafo con riquadro"*. La regola del 1 ottobre e' superata: il
/// secondo paragrafo sta nel riquadro dorato "Cosa fare adesso", in Breve e
/// in Lunga; il terzo, l'approfondimento, sta nel testo; il quarto, il rito
/// propiziatorio, sta nel riquadro arancione del rito (voci GA.03 e GA.04).
/// Questa prova, che difendeva il terzo, adesso difende i due riquadri della
/// forma nuova, nella stessa grandezza: dove sta ogni paragrafo.
///
/// Si misura: nelle schede del Giorno delle tre tradizioni, montate con
/// [IlResponsoInterpretato] come le monta la scheda dell'Oroscopo, e nelle
/// schede della Settimana e del Mese ([IlPeriodoView]), in Lunga e in
/// Breve: il secondo paragrafo nel riquadro dorato, una volta per scheda; il
/// terzo fuori da ogni riquadro; il quarto nel riquadro arancione; in Breve
/// nessun riquadro arancione.
void main() {
  final p = dodiciPersone[0];
  final oggi = DateTime(2026, 10, 1);
  var schede = 0;
  final colpe = <String>[];

  Future<void> monta(WidgetTester tester, Widget w) async {
    tester.view.physicalSize = const Size(390, 20000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SingleChildScrollView(child: w))));
    await tester.pump();
  }

  /// Dove stanno i paragrafi del responso di [chiave].
  void misura(String dove, String chiave, {required bool lunga}) {
    schede++;
    Finder k(String nome) => find.byKey(Key('${chiave}_$nome'));
    bool dentro(Finder f, Type t) =>
        find.ancestor(of: f, matching: find.byType(t)).evaluate().isNotEmpty;
    if (k('cosa_fare').evaluate().isEmpty ||
        !dentro(k('cosa_fare'), RiquadroInEvidenza)) {
      colpe.add('$dove: il secondo paragrafo non sta nel riquadro dorato');
    }
    if (dentro(k('risposta'), RiquadroInEvidenza) ||
        dentro(k('risposta'), RiquadroArancione)) {
      colpe.add('$dove: il primo paragrafo sta in un riquadro');
    }
    if (lunga) {
      if (k('approfondimento').evaluate().isEmpty) {
        colpe.add('$dove: manca il terzo paragrafo');
      } else if (dentro(k('approfondimento'), RiquadroInEvidenza) ||
          dentro(k('approfondimento'), RiquadroArancione)) {
        colpe.add('$dove: il terzo paragrafo sta ancora in un riquadro');
      }
      if (k('rito').evaluate().isEmpty ||
          !dentro(k('rito'), RiquadroArancione)) {
        colpe.add('$dove: il quarto paragrafo non sta nel riquadro del rito');
      }
    } else if (k('rito').evaluate().isNotEmpty ||
        k('approfondimento').evaluate().isNotEmpty) {
      colpe.add('$dove: la Breve porta i paragrafi della Lunga');
    }
  }

  for (final t in TradizioneEu.values) {
    for (final lunga in const [true, false]) {
      testWidgets('il Giorno ${t.name} in ${lunga ? 'Lunga' : 'Breve'}',
          (tester) async {
        for (final c in p.giorno(t, oggi, lunga: lunga)) {
          await monta(
              tester,
              IlResponsoInterpretato(
                  responso: c.responso!,
                  chiave: 'scheda',
                  palette: MaestroPalette.medora,
                  mostraIlTitolo: false,
                  stileDelTitolo: TypographyTokens.titoloScheda(),
                  stile: TypographyTokens.lettura()));
          misura('${t.name} ${c.domain.name} ${lunga ? 'Lunga' : 'Breve'}',
              'scheda',
              lunga: lunga);
        }
      });
    }
    for (final mese in const [false, true]) {
      for (final lunga in const [true, false]) {
        final nome = '${mese ? 'il Mese' : 'la Settimana'} ${t.name} in '
            '${lunga ? 'Lunga' : 'Breve'}';
        testWidgets(nome, (tester) async {
          if (!p.legge(t)) return;
          final periodo = p.periodo(t, oggi, mese: mese);
          await monta(
              tester,
              IlPeriodoView(
                periodo: periodo,
                mese: mese,
                palette: MaestroPalette.medora,
                livello: LivelloPersonalizzazione.cartaCompleta,
                profondita: {
                  for (final d in HoroscopeDomain.values)
                    d: lunga ? AnswerDepth.profonda : AnswerDepth.free,
                },
                premiumUnlocked: true,
                onDepthSelected: (_, __) {},
                onDepthLocked: (_, __) {},
              ));
          for (final d in HoroscopeDomain.values) {
            misura('$nome ${d.name}', 'oroscopo_periodo_${d.name}',
                lunga: lunga);
          }
        });
      }
    }
  }

  tearDownAll(() => print('IL TERZO PARAGRAFO DELLA LUNGA, DALL\'ORDINE GA I '
      'DUE RIQUADRI: schede $schede, difetti ${colpe.length}'));

  test('i conti', () {
    // Tre tradizioni: il Giorno in Lunga e in Breve (4 + 4), la Settimana e
    // il Mese in Lunga e in Breve (4 per ognuno): 24 schede per tradizione.
    cardinaleMinimo(schede, 72, cosa: 'schede guardate');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
