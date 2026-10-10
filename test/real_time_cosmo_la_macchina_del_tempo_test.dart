// LA MACCHINA DEL TEMPO: LA CORSA E LE SUE REGOLE. Aggiunta all'ordine FH,
// voci D1, D8, E1, E2, E5 e E11.
//
// La corsa verso una data che non e' la nascita dura sei secondi per
// qualunque distanza (E1), indietro o avanti (E2), col tetto di 24 istanti al
// secondo, e ogni istante e' un istante vero del cielo: oltre 430 giorni con
// la regola della corsa FG, fra 12 e 430 a giorni siderali interi, sotto i 12
// continua. Le ruote stanno nella finestra 1900-2100 (D1) e il 29 febbraio
// esiste solo negli anni bisestili (D8). Le frasi d'arrivo sono quelle
// dell'Architetto (E11).

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/il_riavvolgimento.dart';
import 'package:esoteric_circle/features/real_time_cosmo/il_tempo_del_cosmo.dart';
import 'package:flutter_test/flutter_test.dart';

double _norm(double a) => ((a % 360) + 360) % 360;
double _scarto(double a, double b) => (_norm(a - b + 180) - 180).abs();

PianoDelRiavvolgimento _corsa(DateTime da, DateTime a) =>
    PianoDelRiavvolgimento.corsaFra(
      jdDa: Celestial.julianDay(da),
      jdA: Celestial.julianDay(a),
      latDa: 45.46,
      lonDa: 9.19,
      latA: 40.85,
      lonA: 14.27,
    );

void _ilTetto(PianoDelRiavvolgimento p) {
  expect(p.durata, kDurataDellaMacchina);
  expect((p.length - 1) / p.durata <= kIstantiAlSecondo, isTrue,
      reason: '${p.length} istanti in ${p.durata} secondi');
}

void main() {
  test('una corsa lunga, indietro e avanti, in sei secondi', () {
    final adesso = DateTime.utc(2026, 10, 8, 20);
    for (final arrivo in [
      DateTime.utc(1900, 1, 1, 11),
      DateTime.utc(1946, 6, 2, 12),
      DateTime.utc(2100, 12, 31, 11),
    ]) {
      final p = _corsa(adesso, arrivo);
      _ilTetto(p);
      final jdDa = Celestial.julianDay(adesso),
          jdA = Celestial.julianDay(arrivo);
      expect(p.istanti.first, jdDa);
      expect(p.istanti.last, jdA);
      final basso = jdDa < jdA ? jdDa : jdA, alto = jdDa < jdA ? jdA : jdDa;
      for (final t in p.istanti) {
        expect(t >= basso && t <= alto, isTrue, reason: 'istante fuori');
        // Dentro la finestra verificata delle effemeridi.
        expect(IlCieloDiMeeus.verificato(t), isTrue);
      }
      // La data mostrata scende (o sale) sempre, a velocita' costante.
      final meta = p.dataAlPunto((p.length - 1) / 2);
      expect(meta, closeTo((jdDa + jdA) / 2, 1e-6));
      var prima = p.dataAlPunto(0);
      for (var k = 1; k < p.length; k++) {
        final d = p.dataAlPunto(k.toDouble());
        expect(jdA < jdDa ? d <= prima : d >= prima, isTrue);
        prima = d;
      }
    }
  });

  test('a giorni siderali interi fra 12 e 430 giorni: le stelle ferme', () {
    final da = DateTime.utc(2026, 10, 8, 20);
    final a = DateTime.utc(2027, 1, 16, 20); // cento giorni avanti
    final p = _corsa(da, a);
    _ilTetto(p);
    final lstA = Celestial.localSiderealDegrees(p.istanti.last, 14.27);
    for (var k = 1; k < p.length; k++) {
      expect(p.istanti[k] - p.istanti[k - 1], greaterThan(0.99));
      final lst =
          Celestial.localSiderealDegrees(p.istanti[k], p.longitudini[k]);
      // Il luogo scivola: il tempo siderale si confronta col luogo dell'arrivo
      // solo dove il luogo e' gia' arrivato.
      if (k == p.length - 1) expect(_scarto(lst, lstA), lessThan(0.05));
    }
  });

  test('sotto i dodici giorni il tempo scorre continuo', () {
    final da = DateTime.utc(2026, 10, 8, 20);
    final p = _corsa(da, DateTime.utc(2026, 10, 13, 20));
    _ilTetto(p);
    for (var k = 1; k < p.length; k++) {
      expect(
          p.istanti[k] - p.istanti[k - 1], closeTo(5 / (p.length - 1), 1e-9));
    }
  });

  test('le ruote stanno nella finestra e il 29 febbraio nei bisestili', () {
    expect(giornoValido(1899, 12, 31), DateTime(1900, 12, 31));
    expect(giornoValido(2101, 1, 1), DateTime(2100, 1, 1));
    expect(giornoValido(2024, 2, 29), DateTime(2024, 2, 29));
    expect(giornoValido(2023, 2, 29), DateTime(2023, 2, 28));
    // Il 2100 non e' bisestile, il 2000 si'.
    expect(giornoValido(2100, 2, 29), DateTime(2100, 2, 28));
    expect(giornoValido(2000, 2, 29), DateTime(2000, 2, 29));
    expect(giornoValido(2026, 4, 31), DateTime(2026, 4, 30));
  });

  test('le frasi d\'arrivo e la riga che corre', () {
    final oggi = DateTime(2026, 10, 10);
    final nascita = DateTime(1988, 5, 14);
    expect(arrivoAl(DateTime(1988, 5, 14), nascita, oggi),
        ArrivoDellaCorsa.nascita);
    expect(
        arrivoAl(DateTime(2026, 10, 10), nascita, oggi), ArrivoDellaCorsa.oggi);
    expect(arrivoAl(DateTime(1950, 3, 1), nascita, oggi),
        ArrivoDellaCorsa.passato);
    expect(
        arrivoAl(DateTime(2100, 12, 31), null, oggi), ArrivoDellaCorsa.futuro);
    expect(fraseDArrivo(ArrivoDellaCorsa.passato, '14 marzo 1987'),
        'QUESTO ERA IL CIELO DEL 14 marzo 1987');
    expect(
        fraseDArrivo(ArrivoDellaCorsa.oggi, ''), 'QUESTO È IL CIELO DI OGGI');
    expect(fraseDArrivo(ArrivoDellaCorsa.futuro, '31 dicembre 2100'),
        'QUESTO SARÀ IL CIELO DEL 31 dicembre 2100');
    expect(fraseDArrivo(ArrivoDellaCorsa.nascita, ''), kFraseDellaNascita);
    expect(rigaDellaCorsa(versoIlPassato: true),
        'STO TORNANDO INDIETRO NEL TEMPO');
    expect(
        rigaDellaCorsa(versoIlPassato: false), 'STO ANDANDO AVANTI NEL TEMPO');
  });
}
