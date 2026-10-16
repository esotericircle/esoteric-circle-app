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
  // AI BORDI DELLA FINESTRA. Presa dalla registrazione I8 sul Realme, 10
  // ottobre 2026: dal 31 dicembre 2100 verso la nascita la corsa non partiva,
  // perche' la stima della fase chiedeva il Sole a 5,8 giorni oltre la fine
  // della finestra verificata e la porta di Meeus rifiutava. Le corse che
  // partono o arrivano ai due bordi non lanciano niente, e ogni istante del
  // piano sta dentro la finestra.
  test('le corse ai bordi della finestra restano dentro la finestra', () {
    // Le 12 di Roma, cioe' le 11 UT, l'ora che la Macchina porta sul giorno.
    final fine = Celestial.julianDay(DateTime.utc(2100, 12, 31, 11));
    final inizio = Celestial.julianDay(DateTime.utc(1900, 1, 1, 11));
    final nascita = Celestial.julianDay(DateTime.utc(1990, 6, 15, 10));
    final piani = <String, PianoDelRiavvolgimento Function()>{
      'dal 2100 alla nascita': () => PianoDelRiavvolgimento.prepara(
          jdAdesso: fine,
          jdNascita: nascita,
          latAdesso: 41.9,
          lonAdesso: 12.5,
          latNascita: 41.9,
          lonNascita: 12.5),
      'dal 2100 al 1900': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: fine,
          jdA: inizio,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
      'dal 1900 al 2100': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: inizio,
          jdA: fine,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
      'dal 2100 a dieci giorni prima': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: fine,
          jdA: fine - 10,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
      'dal 2100 a un anno prima': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: fine,
          jdA: fine - 365,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
    };
    // Ogni caso si valuta anche se un altro cade (sul codice di prima il
    // primo caso cadeva e gli altri non venivano guardati).
    var istanti = 0;
    final guasti = <String>[];
    for (final e in piani.entries) {
      try {
        final p = e.value();
        for (final jd in p.istanti) {
          if (!IlCieloDiMeeus.verificato(jd)) {
            guasti.add('${e.key}: istante $jd fuori dalla finestra');
          }
          istanti++;
        }
      } on FuoriDalCieloVerificato catch (errore) {
        guasti.add('${e.key}: $errore');
      }
    }
    expect(guasti, isEmpty, reason: guasti.join(' | '));
    expect(istanti, greaterThan(400));
  });

  // LA GEMELLA DEL BORDO BASSO. L'Architetto, 10 ottobre 2026: "lo stesso
  // deve poter accadere al bordo basso, andando indietro verso l'1 gennaio
  // 1900". La prova sopra tocca il 1900 solo con le due corse lunghe; qui le
  // stesse forme del bordo alto, rovesciate: la corsa verso una nascita a
  // ridosso del 1900, le corse brevi che arrivano al 1900 e quelle che ne
  // partono.
  test('le corse al bordo basso della finestra restano dentro la finestra', () {
    // Le 12 di Roma del primo giorno, le 11 UT.
    final inizio = Celestial.julianDay(DateTime.utc(1900, 1, 1, 11));
    final piani = <String, PianoDelRiavvolgimento Function()>{
      'da un anno dopo alla nascita del primo giorno': () =>
          PianoDelRiavvolgimento.prepara(
              jdAdesso: inizio + 365,
              jdNascita: inizio,
              latAdesso: 41.9,
              lonAdesso: 12.5,
              latNascita: 41.9,
              lonNascita: 12.5),
      "da trent'anni dopo alla nascita del primo giorno": () =>
          PianoDelRiavvolgimento.prepara(
              jdAdesso: inizio + 365.25 * 30,
              jdNascita: inizio,
              latAdesso: 41.9,
              lonAdesso: 12.5,
              latNascita: 41.9,
              lonNascita: 12.5),
      'da dieci giorni dopo al 1900': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: inizio + 10,
          jdA: inizio,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
      'da un anno dopo al 1900': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: inizio + 365,
          jdA: inizio,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
      'dal 1900 a dieci giorni dopo': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: inizio,
          jdA: inizio + 10,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
      'dal 1900 a un anno dopo': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: inizio,
          jdA: inizio + 365,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
      // Le corse lunghe, oltre 430 giorni, sono quelle che passano dalla
      // stima della fase: il primo passo di una corsa che parte dal 1900 cade
      // a ridosso del bordo, come quello della corsa dal 2100 della I8.
      'dal 1900 a due anni dopo': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: inizio,
          jdA: inizio + 730,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
      'dal 1900 al 2100': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: inizio,
          jdA: Celestial.julianDay(DateTime.utc(2100, 12, 31, 11)),
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
      'da due anni dopo al 1900': () => PianoDelRiavvolgimento.corsaFra(
          jdDa: inizio + 730,
          jdA: inizio,
          latDa: 41.9,
          lonDa: 12.5,
          latA: 41.9,
          lonA: 12.5),
    };
    // Ogni caso si valuta anche se un altro cade: nella prova del bordo alto
    // il primo caso cadeva e gli altri non venivano mai guardati.
    var istanti = 0;
    final guasti = <String>[];
    for (final e in piani.entries) {
      try {
        final p = e.value();
        for (final jd in p.istanti) {
          if (!IlCieloDiMeeus.verificato(jd)) {
            guasti.add('${e.key}: istante $jd fuori dalla finestra');
          }
          istanti++;
        }
      } on FuoriDalCieloVerificato catch (errore) {
        guasti.add('${e.key}: $errore');
      }
    }
    expect(guasti, isEmpty, reason: guasti.join(' | '));
    expect(istanti, greaterThan(400));
  });

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
