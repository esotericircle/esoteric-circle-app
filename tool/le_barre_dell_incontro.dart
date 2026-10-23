// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE BARRE DELL'INCONTRO, PRIMA E DOPO.** Ordine ER voce 05.
///
/// Venti coppie: la percentuale vera, la barra di prima (l'indice sulla
/// scala di chi guarda, un quinto del tetto) e quella di adesso. Si lancia
/// con `flutter test tool/le_barre_dell_incontro.dart`.
void main() {
  test('le barre dell\'incontro', () {
    final righe = <String>[
      'ER.05, LA POSSIBILITÀ DI INCONTRO: VENTI COPPIE, PRIMA E DOPO, 27 '
          'settembre 2026',
      '',
      'Chi guarda: il cielo di ${VipCatalog.vips[9].name} al posto della '
          'persona; giorno 28 agosto 2026. PRIMA: la barra portava '
          'l\'indice sulla scala di chi guarda (percentuale / 3,6 punti) e '
          'a destra una parola. DOPO: la barra e\' la percentuale vera, a '
          'destra il numero.',
      '',
    ];
    var piuLunghePrima = 0;
    var piuLungheDopo = 0;
    var coppie = 0;
    for (var i = 0; i < VipCatalog.vips.length && coppie < 20; i++) {
      final r = SynastryReport.perCieli(
          tuo: CieloDiSinastria.perVip(VipCatalog.vips[9]),
          vip: VipCatalog.vips[i],
          quando: DateTime(2026, 8, 28));
      if (!r.incontro.esiste) continue;
      coppie++;
      final vero = r.incontro.percento;
      final prima = r.incontro.indiceSullaScala.toDouble();
      final dopo = r.bars.firstWhere((b) => b.quip.isNotEmpty).frazione * 100;
      if (prima > vero + 1e-9) piuLunghePrima++;
      if (dopo > vero + 1e-9) piuLungheDopo++;
      righe.add('${VipCatalog.vips[i].name.padRight(20)} vera '
          '${r.meetingLabel.padLeft(6)}  barra prima '
          '${prima.toStringAsFixed(1).padLeft(5)}% ("${r.incontro.inParole}")'
          '  barra dopo ${dopo.toStringAsFixed(1).padLeft(5)}% '
          '("${r.meetingLabel}")');
    }
    righe
      ..add('')
      ..add('Barre dell\'incontro piu\' lunghe della loro percentuale vera: '
          'prima $piuLunghePrima su $coppie, dopo $piuLungheDopo su $coppie.');
    File('docs/collaudo/ER/incontro.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
    print(righe.last);
  });
}
