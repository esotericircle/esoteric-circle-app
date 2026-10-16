// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'package:esoteric_circle/core/astro/meeus/la_luna_intera.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA DISTANZA TERRA-LUNA IN CHILOMETRI.** Ordine FX voce 1, 16 ottobre
/// 2026.
///
/// La tabella 47.A di Meeus aveva solo la colonna della longitudine: questa
/// prova misura la colonna nuova, la distanza, appena aggiunta a
/// `LaLunaIntera` e esposta da `IlCieloDiMeeus.distanzaInKm`.
///
/// **Due fonti indipendenti dal calcolo che si verifica.**
/// - L'esempio 47.a del libro di Meeus, *Astronomical Algorithms* (2a ed.
///   1998), pagina 342: 12 aprile 1992, 0h TD, distanza 368409,7 km.
/// - Quattro istanti esatti di perigeo e apogeo del 2026, in tempo
///   universale, pubblicati da moonblink.info
///   (https://moonblink.info/Eclipse/astro/table/2026): all'istante esatto
///   la distanza e' all'estremo, quindi la sua derivata e' zero e un piccolo
///   scarto sull'istante pubblicato (al secondo) sposta la distanza di pochi
///   metri, non di chilometri.
void main() {
  test('l\'esempio 47.a di Meeus: 12 aprile 1992, 0h TD, 368409,7 km', () {
    final d = LaLunaIntera.distanzaInKmTd(2448724.5);
    print('ORDINE FX: esempio 47.a, distanza ${d.toStringAsFixed(1)} km');
    expect(d, closeTo(368409.7, 1.0));
  });

  test('quattro perigei e apogei del 2026 contro moonblink.info', () {
    final righe = <(DateTime, double, String)>[
      (DateTime.utc(2026, 1, 1, 21, 44, 35), 360350, 'perigeo 1 gennaio'),
      (DateTime.utc(2026, 1, 13, 20, 48, 46), 405436, 'apogeo 13 gennaio'),
      (DateTime.utc(2026, 6, 1, 4, 33, 38), 406365, 'apogeo 1 giugno'),
      (DateTime.utc(2026, 6, 14, 23, 18, 56), 357199, 'perigeo 14 giugno'),
    ];
    cardinaleMinimo(righe.length, 4, cosa: 'istanti di perigeo o apogeo');
    var peggiore = 0.0;
    for (final (quando, pubblicato, nome) in righe) {
      final jd = IlCieloDiMeeus.giornoGiuliano(quando);
      final calcolato = IlCieloDiMeeus.distanzaInKm(jd);
      final scarto = (calcolato - pubblicato).abs();
      if (scarto > peggiore) peggiore = scarto;
      print('ORDINE FX: $nome, calcolato ${calcolato.toStringAsFixed(1)} km, '
          'pubblicato $pubblicato km, scarto ${scarto.toStringAsFixed(1)} km');
    }
    print('ORDINE FX: scarto massimo sui perigei e apogei 2026 '
        '${peggiore.toStringAsFixed(1)} km');
    // All'istante esatto dell'estremo la distanza e' piatta: un errore di
    // qualche secondo sull'istante pubblicato pesa pochi metri, non
    // chilometri. La soglia resta larga per l'incertezza residua del Delta T
    // e dell'istante pubblicato al secondo.
    expect(peggiore, lessThan(2.0));
  });
}
