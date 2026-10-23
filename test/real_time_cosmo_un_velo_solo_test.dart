// IL VELO E' SEMPRE UNO SOLO. Ordine FH voce 15.1.
//
// La camera della schermata vera spazza tutto il giro dell'orizzonte a tre
// altezze, con passi di circa sei gradi, cosi' passa anche sui confini fra
// due segni, e a ogni fotogramma si contano i veli disegnati: quelli che il
// pittore posa (una posa e una luce sopra zero). La guardia cade se in un
// qualunque fotogramma sono due. Cardinale minimo dichiarato: almeno 300
// fotogrammi guardati e almeno tre veli diversi visti accesi, altrimenti la
// spazzata non ha guardato niente.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:esoteric_circle/features/real_time_cosmo/pittore_del_cielo.dart';

import 'le_anteprime_dell_ordine_fg_test.dart' as fg;
import 'le_anteprime_dell_ordine_fh_test.dart' as fh;

void main() {
  testWidgets('in nessun fotogramma i veli disegnati sono due', (tester) async {
    await fh.monta(tester, fg.cielo(ModoDelCielo.adesso));
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final f = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<PittoreDelCielo>()
        .first
        .fotogramma;
    final centro =
        tester.getCenter(find.byKey(const Key('real_time_cosmo_cielo')));
    var fotogrammi = 0, peggio = 0;
    final visti = <Object>{};
    Future<void> guarda() async {
      for (var k = 0; k < 4; k++) {
        await tester.pump(const Duration(milliseconds: 40));
        fotogrammi++;
        var disegnati = 0;
        for (final v in f.veli) {
          if (v.posa != null && v.luce > 0) {
            disegnati++;
            visti.add(v);
          }
        }
        if (disegnati > peggio) peggio = disegnati;
        expect(disegnati, lessThanOrEqualTo(1),
            reason: 'fotogramma $fotogrammi: $disegnati veli disegnati');
      }
    }

    // Tre altezze: lo sguardo scende, sta a meta', sale.
    for (final su in [2, -2, -2]) {
      for (var i = 0; i < su.abs(); i++) {
        await tester.dragFrom(centro, Offset(0, su > 0 ? -40 : 40));
        await tester.pump(const Duration(milliseconds: 40));
      }
      for (var passo = 0; passo < 30; passo++) {
        await tester.dragFrom(centro, const Offset(30, 0));
        await guarda();
      }
    }
    // ignore: avoid_print
    print('UN VELO SOLO: fotogrammi guardati $fotogrammi, veli diversi visti '
        'accesi ${visti.length}, massimo disegnati insieme $peggio');
    expect(fotogrammi, greaterThanOrEqualTo(300));
    expect(visti.length, greaterThanOrEqualTo(3));
  });
}
