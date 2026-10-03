// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/synastry/cielo_del_giorno_sulla_coppia.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SINASTRIA DICE LE COSE UNA VOLTA, E IN ITALIANO.** Ordine ER voci 17
/// e 18, 27 settembre 2026.
///
/// ER.17: sotto la barra si leggeva *"Non si sa pubblicamente dove viva,
/// quindi la distanza non entra nel conto"* e subito dopo *"Dove viva non è
/// cosa pubblica, quindi la distanza non entra nel conto."*
///
/// ER.18: *"Oggi Marte passa sul grado di Venere Quadratura Marte"*: il
/// titolo della lista, con le maiuscole, dentro una frase.
void main() {
  test('ER.17: ogni VIP senza luogo pubblico lo dice una volta sola', () {
    final tuo = CieloDiSinastria.perVip(VipCatalog.vips[9]);
    var senzaLuogo = 0;
    final dueVolte = <String>[];
    for (final vip in VipCatalog.vips) {
      if (vip.luogoDiOggi != null || vip.eScomparso) continue;
      senzaLuogo++;
      final r = SynastryReport.perCieli(
          tuo: tuo, vip: vip, quando: DateTime(2026, 8, 28));
      final responso = [...r.bars.map((b) => b.quip), r.nota].join(' ');
      final volte =
          'la distanza non entra nel conto'.allMatches(responso).length;
      if (volte != 1) dueVolte.add('${vip.name}: $volte');
    }
    print('ORDINE ER VOCE 17: VIP senza luogo pubblico $senzaLuogo, responsi '
        'che non lo dicono una volta sola ${dueVolte.length}');
    expect(senzaLuogo, greaterThanOrEqualTo(10),
        reason: 'la prova non ha trovato abbastanza VIP senza luogo');
    expect(dueVolte, isEmpty,
        reason: 'responsi che non dicono una volta sola che la distanza non '
            'entra nel conto: $dueVolte');
  });

  test('ER.18: la riga del cielo nomina il legame in italiano, in ogni forma',
      () {
    final righe = <String>[
      'ER.18, LA RIGA DEL CIELO DEL GIORNO, PER OGNI TIPO DI ASPETTO E PER LE '
          'TRE FORME, 27 settembre 2026',
      '',
    ];
    final colTitolo = <String>[];
    for (final tipo in AspectType.values) {
      final a = AspettoDiSinastria(
        tuo: PuntoDelCielo.marte,
        suo: PuntoDelCielo.venere,
        tipo: tipo,
        orbo: 1,
        nomeSuo: 'Margot Robbie',
      );
      for (final valore in [1.8, 1.2, 0.6]) {
        final riga = MoltiplicatoreCeleste(
          valore: valore,
          transito: CorpoCeleste.marte,
          aspettoAcceso: a,
          soloPianeti: true,
        ).riga;
        righe.add(riga);
        if (riga.contains(a.titolo) ||
            RegExp(r'\s(Congiunzione|Sestile|Quadratura|Trigono|Opposizione)\b')
                .hasMatch(riga)) {
          colTitolo.add(riga);
        }
      }
    }
    Directory('docs/collaudo/ER').createSync(recursive: true);
    File('docs/collaudo/ER/cielo_del_giorno.txt').writeAsStringSync(
        '${righe.join('\n')}\n\nFrasi col titolo dell\'aspetto in maiuscolo '
        'dentro la frase: ${colTitolo.length} su ${righe.length - 2}.\n');
    expect(colTitolo, isEmpty,
        reason: 'frasi col titolo dell\'aspetto dentro: $colTitolo');
  });
}
