// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/horoscope/il_periodo_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **"DA DOVE VIENE" NON SI RIPETE NEL PERIODO.** Ordine EU voci 01 e 02,
/// vista sul Realme il 1 ottobre 2026.
///
/// Il fondatore: *"i testi sono importantissimi e devono seguire le regole
/// per le risposte es evitare ripetizioni"*. Nella Settimana Lunga della
/// Vedica il giorno migliore stava due volte: nella riga dei tre giorni
/// migliori col suo "Da dove viene", e subito sotto in fondo alla scheda,
/// "Da dove viene: il giorno migliore, martedì 6 ottobre: Il livello viene
/// dalla Luna...", con la stessa frase e la maiuscola dopo i due punti.
///
/// Si misura, per ogni dominio della Settimana e del Mese, in Lunga, nelle
/// tre tradizioni: le righe "Da dove viene" della scheda in cui la ragione di
/// un'altra riga torna intera (0), e quelle con la maiuscola di un articolo
/// dopo i due punti (0).
void main() {
  final persone = [dodiciPersone[0], dodiciPersone[1], dodiciPersone[2]];
  final oggi = DateTime(2026, 10, 1);

  /// Il cuore di una riga: quello che viene dopo l'ultimo "Da dove viene:"
  /// e dopo il giorno migliore, in minuscolo.
  String cuore(String riga) {
    var s = riga.replaceFirst('Da dove viene: ', '');
    final giorno = RegExp(r'^il giorno migliore, [^:]+: ').firstMatch(s);
    if (giorno != null) s = s.substring(giorno.end);
    return s.toLowerCase().trim();
  }

  var schedeGuardate = 0;
  final ripetute = <String>[];
  final maiuscole = <String>[];

  for (final t in TradizioneEu.values) {
    for (final mese in const [false, true]) {
      testWidgets('${t.name} ${mese ? 'Mese' : 'Settimana'} Lunga',
          (tester) async {
        tester.view.physicalSize = const Size(390, 20000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        for (final p in persone) {
          if (!p.legge(t)) continue;
          final periodo = p.periodo(t, oggi, mese: mese);
          await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(390, 20000), disableAnimations: true),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: IlPeriodoView(
                    periodo: periodo,
                    mese: mese,
                    palette: MaestroPalette.medora,
                    livello: p.conCarta
                        ? LivelloPersonalizzazione.cartaCompleta
                        : LivelloPersonalizzazione.soloSegno,
                    profondita: {
                      for (final d in HoroscopeDomain.values)
                        d: AnswerDepth.profonda,
                    },
                    premiumUnlocked: true,
                    onDepthSelected: (_, __) {},
                    onDepthLocked: (_, __) {},
                  ),
                ),
              ),
            ),
          ));
          await tester.pump();
          expect(tester.takeException(), isNull);
          List<String> daDoveIn(Finder dove) => [
                for (final e in find
                    .descendant(
                        of: dove, matching: find.byType(Text), matchRoot: true)
                    .evaluate())
                  if (((e.widget as Text).data ?? '')
                      .startsWith('Da dove viene'))
                    (e.widget as Text).data!,
              ];
          for (final d in HoroscopeDomain.values) {
            schedeGuardate++;
            // Le righe dei tre giorni migliori, e la riga in fondo alla
            // scheda (che nella Lunga puo' non esserci).
            final deiGiorni = daDoveIn(find.byWidgetPredicate((w) =>
                w.key is ValueKey<String> &&
                (w.key as ValueKey<String>)
                    .value
                    .startsWith('oroscopo_periodo_riga_${d.name}_')));
            final inFondo =
                daDoveIn(find.byKey(Key('oroscopo_periodo_da_dove_${d.name}')));
            for (final r in [...deiGiorni, ...inFondo]) {
              if (RegExp(r': (Il|Lo|La|Gli|Le|I|Un|Una|Oggi) ')
                  .hasMatch(r.replaceFirst('Da dove viene: ', ''))) {
                maiuscole.add('${p.nome} ${t.name} ${d.name}: $r');
              }
            }
            for (final f in inFondo) {
              for (final g in deiGiorni) {
                final a = cuore(f), b = cuore(g);
                if (b.length > 20 && a.contains(b)) {
                  ripetute.add('${p.nome} ${t.name} '
                      '${mese ? 'Mese' : 'Settimana'} ${d.name}: '
                      '"$f" ripete "$g"');
                }
              }
            }
          }
        }
      });
    }
  }

  tearDownAll(() {
    print('ORDINE EU, DA DOVE VIENE NEL PERIODO: schede guardate '
        '$schedeGuardate, righe che ne ripetono un\'altra ${ripetute.length}, '
        'maiuscole dopo i due punti ${maiuscole.length}');
  });

  test('i conti', () {
    // Gira dopo le prove sopra, nello stesso file: le liste sono piene.
    cardinaleMinimo(schedeGuardate, 64,
        cosa: 'schede del periodo guardate',
        perche: 'tre persone, tre tradizioni (la Vedica senza Luna di '
            'nascita ne salta una), due periodi, quattro domini');
    expect(ripetute, isEmpty, reason: ripetute.take(6).join('\n'));
    expect(maiuscole, isEmpty, reason: maiuscole.take(6).join('\n'));
  });
}
