// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/design_system/components/riquadro_in_evidenza.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
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
/// Si misura: nelle schede del Giorno di tre tradizioni in Lunga (la porta
/// dei paragrafi, come le monta l'oroscopo dell'amico) e nelle schede della
/// Settimana e del Mese in Lunga, il riquadro c'e' una volta per scheda e
/// contiene il terzo paragrafo; in Breve non c'e'.
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

  for (final t in TradizioneEu.values) {
    for (final lunga in const [true, false]) {
      testWidgets('il Giorno ${t.name} in ${lunga ? 'Lunga' : 'Breve'}',
          (tester) async {
        for (final c in p.giorno(t, oggi, lunga: lunga)) {
          await monta(
              tester,
              ParagrafiDiLettura(
                  terzoInEvidenza: true,
                  testo: c.text,
                  stile: TypographyTokens.lettura()));
          schede++;
          final riquadri = find.byKey(const Key('paragrafo_in_evidenza'));
          final paragrafi = c.text.split('\n\n');
          if (lunga) {
            if (riquadri.evaluate().length != 1 ||
                find
                    .descendant(of: riquadri, matching: find.text(paragrafi[2]))
                    .evaluate()
                    .isEmpty) {
              colpe.add('${t.name} ${c.domain.name} Lunga: il terzo paragrafo '
                  'non sta nel riquadro');
            }
          } else if (riquadri.evaluate().isNotEmpty) {
            colpe.add('${t.name} ${c.domain.name} Breve: un riquadro in Breve');
          }
        }
      });
    }
    testWidgets('la Settimana ${t.name} in Lunga', (tester) async {
      if (!p.legge(t)) return;
      final periodo = p.periodo(t, oggi, mese: false);
      await monta(
          tester,
          IlPeriodoView(
            periodo: periodo,
            mese: false,
            palette: MaestroPalette.medora,
            livello: LivelloPersonalizzazione.cartaCompleta,
            profondita: {
              for (final d in HoroscopeDomain.values) d: AnswerDepth.profonda,
            },
            premiumUnlocked: true,
            onDepthSelected: (_, __) {},
            onDepthLocked: (_, __) {},
          ));
      for (final d in HoroscopeDomain.values) {
        schede++;
        final terzo = find.byKey(Key('oroscopo_periodo_paragrafo_${d.name}_2'));
        final dentro =
            find.ancestor(of: terzo, matching: find.byType(RiquadroInEvidenza));
        if (dentro.evaluate().isEmpty) {
          colpe.add('Settimana ${t.name} ${d.name}: il terzo paragrafo fuori '
              'dal riquadro');
        }
      }
    });
  }

  tearDownAll(() => print('IL TERZO PARAGRAFO DELLA LUNGA: schede $schede, '
      'difetti ${colpe.length}'));

  test('i conti', () {
    cardinaleMinimo(schede, 30, cosa: 'schede guardate');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
