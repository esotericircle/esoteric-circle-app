// LA SCRITTA CEDE SENZA LANCIARE. Ordine FM, aggiunta 1, 12 ottobre 2026.
//
// Il fatto: il pulsante "Attiva macchina del tempo" allunga il pie' di
// pagina del cielo di adesso; su una scena bassa il margine di sotto supera
// quello di sopra, e `clamp(margineAlto, altezza - margineBasso - h)` lancia
// ArgumentError perche' il limite alto dell'intervallo e' sotto quello
// basso. Visto nella suite: FH.10 cadeva con "Invalid argument(s): 80.0".
//
// La guardia prova direttamente altezzaCheCede con uno schermo basso e un
// pie' di pagina alto quanto basta a invertire i limiti.

import 'package:esoteric_circle/features/real_time_cosmo/la_scritta_che_cede.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'con un pie\' di pagina che supera lo schermo altezzaCheCede non '
      'lancia, e resta dentro i margini', () {
    // Uno schermo basso (come la prova FH.10) e un margine di sotto che, con
    // margineAlto, eccede l'altezza: altezza - margineBasso - h < margineAlto.
    const altezza = 260.0;
    const margineAlto = 80.0;
    const margineBasso = 220.0;
    const h = 64.0;
    expect(altezza - margineBasso - h, lessThan(margineAlto),
        reason: 'la prova non ricrea la condizione che faceva lanciare');

    double chiamata() => altezzaCheCede(
          left: 20,
          top: 100,
          w: 170,
          h: h,
          altezza: altezza,
          margineAlto: margineAlto,
          margineBasso: margineBasso,
          ostacoli: 1,
          ostacolo: (_) => const Rect.fromLTWH(0, 90, 400, 80),
        );

    expect(chiamata, returnsNormally,
        reason: 'altezzaCheCede lancia quando il pie\' di pagina supera lo '
            'schermo');
    final t = chiamata();
    expect(t, greaterThanOrEqualTo(margineAlto),
        reason: 'la scritta sale sopra il margine alto');
  });
}
