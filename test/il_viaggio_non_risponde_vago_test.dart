// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL VIAGGIO PRENDE POSIZIONE NELLA PRIMA FRASE. Ordine ES voce 25, 29
/// settembre 2026.**
///
/// Dalla ET.08: *"sì alla riserva che prende posizione, come la propone
/// Code."*, *"Confermo, dobbiamo risolvere tutto."*. La riserva prende
/// posizione; le prime frasi del modello che reggono alle guardie ma restano
/// vaghe tenevano il conto a 14 e 15 su 20. Qui la guardia della prima
/// frase si misura contro i giudizi alla cieca del banco del Viaggio
/// (`docs/collaudo/ET/ciechi/`): sul giro 3, dove e' stata tarata, e sul giro
/// 1, che non ha guardato.
void main() {
  final salute = RegExp(
      r'malat|veterinar|salute|operaz|ospedal|sintom|diagnos|visita|esami',
      caseSensitive: false);

  ({int noPrese, int no, int siPrese, int si}) conta(String giro) {
    const c = 'docs/collaudo/ET/ciechi/';
    final chiave =
        (jsonDecode(File('${c}chiave_viaggio_$giro.json').readAsStringSync())
                as Map)
            .cast<String, dynamic>();
    final giudizi = <String, dynamic>{};
    for (final p in [1, 2]) {
      giudizi.addAll((jsonDecode(
              File('${c}giudizio_viaggio_${giro}_parte$p.json')
                  .readAsStringSync()) as Map)
          .cast<String, dynamic>());
    }
    var noPrese = 0, no = 0, siPrese = 0, si = 0;
    for (final e in chiave.entries) {
      final x = e.value as Map<String, dynamic>;
      // Alle domande di salute la guardia della posizione non vale.
      if (salute.hasMatch(x['domanda'] as String)) continue;
      final presa =
          LeGuardieDelResponso.rimandaLaDomanda(x['risposta'] as String);
      if (giudizi[e.key]['posizione'] == 'no') {
        no++;
        if (presa) noPrese++;
      } else {
        si++;
        if (presa) siPrese++;
      }
    }
    return (noPrese: noPrese, no: no, siPrese: siPrese, si: si);
  }

  test('le prime frasi senza posizione si chiedono di nuovo', () {
    final g3 = conta('giro3');
    final g1 = conta('giro1');
    print('ORDINE ES VOCE 25: giro 3 (tarata) senza posizione prese '
        '${g3.noPrese} su ${g3.no}, buone prese ${g3.siPrese} su ${g3.si}; '
        'giro 1 (non guardato) senza posizione prese ${g1.noPrese} su '
        '${g1.no}, buone prese ${g1.siPrese} su ${g1.si}');
    cardinaleMinimo(g3.no + g3.si, 70, cosa: 'risposte del giro 3');
    cardinaleMinimo(g1.no + g1.si, 70, cosa: 'risposte del giro 1');
    expect(g3.noPrese, greaterThanOrEqualTo(18));
    expect(g3.siPrese, 0);
    expect(g1.noPrese, greaterThanOrEqualTo(8));
    expect(g1.siPrese, lessThanOrEqualTo(3));
    // **IL SECONDO GIRO**, 30 settembre: il banco nuovo (es1) mescolato col
    // giro 3, giudicato alla cieca da giudici nuovi. Con la guardia del
    // primo giro accesa restavano le forme che adesso prende.
    final g4 = conta('es1mix');
    print('ORDINE ES VOCE 25: giro del 30 settembre senza posizione prese '
        '${g4.noPrese} su ${g4.no}, buone prese ${g4.siPrese} su ${g4.si}');
    cardinaleMinimo(g4.no + g4.si, 70, cosa: 'risposte del 30 settembre');
    expect(g4.noPrese, greaterThanOrEqualTo(16));
    expect(g4.siPrese, lessThanOrEqualTo(2));
  });
}
