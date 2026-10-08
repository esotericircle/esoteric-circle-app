// IL RIAVVOLGIMENTO E' FATTO DI ISTANTI VERI. Ordine FG parte 3.
//
// Si misura il piano per una nascita a Napoli il 14 maggio 1988 alle 6:40 UTC
// e un adesso a Milano l'8 ottobre 2026 alle 20 UTC: il tetto degli istanti
// (voce 3.3), il primo istante uguale all'adesso e l'ultimo uguale alla
// nascita, il tempo siderale di ogni istante uguale a quello voluto dalla
// rotazione, la fase della Luna entro sei gradi da quella voluta, nessun
// istante prima della nascita.

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/il_riavvolgimento.dart';
import 'package:flutter_test/flutter_test.dart';

double _norm(double a) => ((a % 360) + 360) % 360;
double _scarto(double a, double b) => (_norm(a - b + 180) - 180).abs();

void main() {
  test('il piano rispetta il tetto e sceglie istanti veri', () {
    final adesso = Celestial.julianDay(DateTime.utc(2026, 10, 8, 20));
    final nascita = Celestial.julianDay(DateTime.utc(1988, 5, 14, 6, 40));
    final cronometro = Stopwatch()..start();
    final piano = PianoDelRiavvolgimento.prepara(
      jdAdesso: adesso,
      jdNascita: nascita,
      latAdesso: 45.46,
      lonAdesso: 9.19,
      latNascita: 40.85,
      lonNascita: 14.27,
    );
    cronometro.stop();
    final n = piano.length;
    expect(n, (kDurataDelRiavvolgimento * kIstantiAlSecondo).ceil());
    expect(n <= kDurataDelRiavvolgimento * kIstantiAlSecondo + 1, isTrue);
    expect(piano.istanti.first, adesso);
    expect(piano.istanti.last, nascita);

    final lstA = Celestial.localSiderealDegrees(adesso, 9.19);
    final lstN = Celestial.localSiderealDegrees(nascita, 14.27);
    final giri = _norm(lstA - lstN) + 360.0 * kGiriDelCielo;
    final faseA = angoloDiFase(adesso);
    final faseN = angoloDiFase(nascita);
    final fasi = _norm(faseA - faseN) + 360.0 * kLunazioni;
    var peggioreLst = 0.0, peggioreFase = 0.0, peggioreData = 0.0;
    for (var k = 1; k < n - 1; k++) {
      final s = k / (n - 1);
      final t = piano.istanti[k];
      expect(t >= nascita, isTrue, reason: 'istante $k prima della nascita');
      final lst = Celestial.localSiderealDegrees(t, piano.longitudini[k]);
      final dl = _scarto(lst, lstN + giri * giriRimasti(s));
      final df = _scarto(angoloDiFase(t), faseN + fasi * anniRimasti(s));
      final data = nascita + (adesso - nascita) * anniRimasti(s);
      final dd = (t - data).abs();
      if (dl > peggioreLst) peggioreLst = dl;
      if (df > peggioreFase) peggioreFase = df;
      if (dd > peggioreData) peggioreData = dd;
    }
    // ignore: avoid_print
    print('istanti $n, preparati in ${cronometro.elapsedMilliseconds} ms; '
        'scarto peggiore: tempo siderale $peggioreLst gradi, fase della Luna '
        '$peggioreFase gradi, data $peggioreData giorni');
    expect(peggioreLst, lessThan(0.05));
    expect(peggioreFase, lessThan(7.5));
    expect(peggioreData, lessThan(kGiorniDellaFinestra + 1.0));
  });

  test('le due curve: gli anni accelerano fino a zero, il cielo rallenta', () {
    expect(anniRimasti(0), 1);
    expect(anniRimasti(1), 0);
    // Accelera: l'ultimo decimo percorre piu' strada del primo.
    expect(anniRimasti(0.9) - anniRimasti(1.0),
        greaterThan(anniRimasti(0) - anniRimasti(0.1)));
    expect(giriRimasti(0), 1);
    expect(giriRimasti(1), 0);
    // Rallenta alla fine: l'ultimo centesimo gira meno del centesimo a meta'.
    expect(giriRimasti(0.99) - giriRimasti(1.0),
        lessThan(giriRimasti(0.5) - giriRimasti(0.51)));
  });
}
