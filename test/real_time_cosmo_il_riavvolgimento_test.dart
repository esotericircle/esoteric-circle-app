// IL RIAVVOLGIMENTO E' FATTO DI ISTANTI VERI. Ordine FG parte 3, ordine FH
// parte 8.
//
// Si misura il piano per una nascita a Napoli il 14 maggio 1988 alle 6:40 UTC
// e un adesso a Milano l'8 ottobre 2026 alle 20 UTC.
//
// LA CORSA (FG): il tetto degli istanti (voce 3.3), il primo istante uguale
// all'adesso, il tempo siderale di ogni istante uguale a quello voluto dalla
// rotazione, la fase della Luna entro sei gradi da quella voluta, nessun
// istante prima del traguardo.
//
// IL RALLENTAMENTO (FH voci 8.1-8.3): l'ultimo anno, ogni istante a un numero
// intero di giorni siderali dalla nascita, i passi mai sotto il giorno, fra
// dodici e tredici lunazioni e mezza mostrate, l'ultimo istante uguale alla
// nascita.
//
// Lapide della regola vecchia: fino all'ordine FG la corsa arrivava DRITTA
// alla nascita in sette secondi, 168 istanti, e la prova pretendeva che il
// piano fosse lungo esattamente quanto la corsa. Dall'ordine FH la corsa si
// ferma un anno prima e la prova misura i due tempi.

import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/il_riavvolgimento.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:flutter_test/flutter_test.dart';

double _norm(double a) => ((a % 360) + 360) % 360;
double _scarto(double a, double b) => (_norm(a - b + 180) - 180).abs();

/// Il giorno siderale in giorni solari.
const double _giornoSiderale = 0.99726957;

final _adesso = Celestial.julianDay(DateTime.utc(2026, 10, 8, 20));
final _nascita = Celestial.julianDay(DateTime.utc(1988, 5, 14, 6, 40));

PianoDelRiavvolgimento _piano(double adesso) => PianoDelRiavvolgimento.prepara(
      jdAdesso: adesso,
      jdNascita: _nascita,
      latAdesso: 45.46,
      lonAdesso: 9.19,
      latNascita: 40.85,
      lonNascita: 14.27,
    );

void main() {
  test('la corsa rispetta il tetto e sceglie istanti veri', () {
    final cronometro = Stopwatch()..start();
    final piano = _piano(_adesso);
    cronometro.stop();
    final fine = piano.fineDellaCorsa;
    final n = fine + 1;
    expect(n, (kDurataDelRiavvolgimento * kIstantiAlSecondo).ceil());
    expect((n - 1) / piano.durataDellaCorsa <= kIstantiAlSecondo, isTrue);
    expect(piano.istanti.first, _adesso);
    final traguardo = piano.istanti[fine];

    final lstA = Celestial.localSiderealDegrees(_adesso, 9.19);
    final lstN = Celestial.localSiderealDegrees(traguardo, 14.27);
    final giri = _norm(lstA - lstN) + 360.0 * kGiriDelCielo;
    final faseA = angoloDiFase(_adesso);
    final faseN = angoloDiFase(traguardo);
    final fasi = _norm(faseA - faseN) + 360.0 * kLunazioni;
    var peggioreLst = 0.0, peggioreFase = 0.0, peggioreData = 0.0;
    var peggioreOltre = -1.0;
    for (var k = 1; k < n - 1; k++) {
      final s = k / (n - 1);
      final t = piano.istanti[k];
      expect(t >= traguardo, isTrue, reason: 'istante $k prima del traguardo');
      final lst = Celestial.localSiderealDegrees(t, piano.longitudini[k]);
      final dl = _scarto(lst, lstN + giri * giriRimasti(s));
      final voluta = faseN + fasi * anniRimasti(s);
      final df = _scarto(angoloDiFase(t), voluta);
      final data = traguardo + (_adesso - traguardo) * anniRimasti(s);
      final dd = (t - data).abs();
      if (dl > peggioreLst) peggioreLst = dl;
      if (df > peggioreFase) peggioreFase = df;
      if (dd > peggioreData) peggioreData = dd;
      // LA FASE SI MISURA ANCHE CONTRO IL MEGLIO POSSIBILE (ordine FH parte
      // 8). I candidati con lo stesso tempo siderale distano un giorno
      // siderale: l'istante scelto non deve essere battuto da quelli accanto
      // (altrimenti la stima ha mancato il migliore) e lo scarto non puo'
      // superare meta' di quanto corre la fase in quel giorno. Il tetto di 7,5
      // gradi da solo non bastava: con le date della corsa nuova la stima
      // vecchia mancava il migliore, e questa misura l'ha vista rossa
      // all'istante 98 (7,93 scelto, 2,88 possibile).
      final prima = angoloDiFase(t - _giornoSiderale);
      final dopo = angoloDiFase(t + _giornoSiderale);
      // Solo i vicini sicuramente dentro la finestra della scelta, che e'
      // larga [kGiorniDellaFinestra] giorni siderali attorno alla data piu'
      // al piu' un giorno.
      bool inFinestra(double u) =>
          u >= traguardo && (u - data).abs() < kGiorniDellaFinestra - 1;
      if (inFinestra(t - _giornoSiderale)) {
        expect(df <= _scarto(prima, voluta) + 1e-6, isTrue,
            reason: 'istante $k: il giorno prima era piu\' vicino');
      }
      if (inFinestra(t + _giornoSiderale)) {
        expect(df <= _scarto(dopo, voluta) + 1e-6, isTrue,
            reason: 'istante $k: il giorno dopo era piu\' vicino');
      }
      final meta = math.max(
              _scarto(prima, angoloDiFase(t)), _scarto(dopo, angoloDiFase(t))) /
          2;
      if (df - meta > peggioreOltre) peggioreOltre = df - meta;
    }
    // ignore: avoid_print
    print('corsa: istanti $n, piano preparato in '
        '${cronometro.elapsedMilliseconds} ms; scarto peggiore: tempo '
        'siderale $peggioreLst gradi, fase della Luna $peggioreFase gradi, '
        'data $peggioreData giorni');
    expect(peggioreLst, lessThan(0.05));
    // ignore: avoid_print
    print('fase oltre la meta del passo del giorno: $peggioreOltre gradi');
    expect(peggioreOltre <= 1e-6, isTrue);
    expect(peggioreFase, lessThan(7.5));
    expect(peggioreData, lessThan(kGiorniDellaFinestra + 1.0));
  });

  test('il rallentamento mostra le ultime lunazioni una per una', () {
    final piano = _piano(_adesso);
    final fine = piano.fineDellaCorsa;
    final passi = piano.length - 1 - fine;
    expect(piano.istanti.last, _nascita);
    expect(passi / piano.durataDelRallentamento <= kIstantiAlSecondo, isTrue);
    expect(piano.durataDelRallentamento, kDurataDelRallentamento);
    // L'ultimo anno: un anno prima della nascita, in giorni siderali interi.
    final anno = piano.istanti[fine] - _nascita;
    expect(anno, closeTo(365.25, 1));
    final lstN = Celestial.localSiderealDegrees(_nascita, 14.27);
    var lunazioni = 0.0;
    var passoMinimo = double.infinity, passoMassimo = 0.0;
    var faseMassima = 0.0, peggioreLst = 0.0;
    for (var k = fine; k < piano.length; k++) {
      final t = piano.istanti[k];
      expect(piano.longitudini[k], 14.27);
      final dl = _scarto(Celestial.localSiderealDegrees(t, 14.27), lstN);
      if (dl > peggioreLst) peggioreLst = dl;
      if (k == fine) continue;
      final passo = piano.istanti[k - 1] - t;
      if (passo < passoMinimo) passoMinimo = passo;
      if (passo > passoMassimo) passoMassimo = passo;
      final df = _norm(angoloDiFase(piano.istanti[k - 1]) - angoloDiFase(t));
      lunazioni += df / 360;
      if (df > faseMassima) faseMassima = df;
    }
    // ignore: avoid_print
    print('rallentamento: istanti $passi in '
        '${piano.durataDelRallentamento} s, passi da $passoMassimo a '
        '$passoMinimo giorni, lunazioni $lunazioni, salto di fase massimo '
        '$faseMassima gradi, tempo siderale fuori di $peggioreLst gradi');
    // Le stelle restano ferme: ogni istante ha il tempo siderale della
    // nascita.
    expect(peggioreLst, lessThan(0.05));
    // Mai sotto il giorno siderale: la Luna non si ferma per poi saltare.
    expect(passoMinimo, greaterThan(0.99));
    expect(passoMassimo, lessThan(3));
    // Le ultime dodici o tredici fasi (voce 8.2).
    expect(lunazioni, inInclusiveRange(12, 13.5));
    // Una per una: nessun salto supera un ottavo di lunazione.
    expect(faseMassima, lessThan(45));
  });

  test('chi e\' nato da pochi mesi non ha la corsa', () {
    final adesso = _nascita + 100.3;
    final piano = _piano(adesso);
    expect(piano.istanti.first, adesso);
    expect(piano.istanti.last, _nascita);
    expect(piano.fineDellaCorsa, 1);
    for (var k = 2; k < piano.length; k++) {
      expect(piano.istanti[k - 1] - piano.istanti[k], greaterThan(0.99));
    }
    expect(
        (piano.length - 2) / piano.durataDelRallentamento <= kIstantiAlSecondo,
        isTrue);
  });

  test('la frase d\'arrivo porta la marca del genere', () {
    expect(
        LaMarcaDelGenere.risolvi(kFraseDellArrivo,
            forma: CourtesyForm.masculine),
        'QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI NATO');
    expect(
        LaMarcaDelGenere.risolvi(kFraseDellArrivo,
            forma: CourtesyForm.feminine),
        'QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI NATA');
    expect(
        LaMarcaDelGenere.risolvi(kFraseDellArrivo, forma: CourtesyForm.unknown),
        'QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI VENUTO AL MONDO');
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
