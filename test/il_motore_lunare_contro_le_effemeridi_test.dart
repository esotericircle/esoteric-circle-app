// IL MOTORE LUNARE CONTRO LE EFFEMERIDI. Ordine FV voce FV.04, 15 ottobre
// 2026.
//
// DOMANDA (l'ordine): "La Luna fuori corso si prova contro una fonte
// esterna: almeno venti intervalli di un anno confrontati con effemeridi
// pubblicate, con lo scarto massimo in minuti dichiarato."
//
// Le fonti stanno in docs/collaudo/FV/fv04_luna_fuori_corso_riferimento.json,
// scritto da tool/lunario_fuori_corso_di_riferimento.py:
// - Moon Tracks (https://www.moontracks.com/void_of_course_moon_aspects.html),
//   ventisette intervalli di ottobre e novembre 2026 in UTC, al minuto;
// - Swiss Ephemeris (pyswisseph, serie Moshier), la stessa definizione
//   calcolata in Python per tutto il 2026, piu' le fasi esatte e la Luna
//   riferita a J2000.
//
// Tutti i confronti si fanno in UTC: la prova vale col fuso del computer di
// Mauro come con quello del cancello di GitHub.

import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/lunario/il_giorno_lunare.dart';
import 'package:esoteric_circle/core/lunario/il_motore_lunare.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// LE SOGLIE, dichiarate: lo scarto massimo misurato il 15 ottobre 2026,
/// arrotondato per eccesso. Moon Tracks pubblica al minuto, quindi contro di
/// lui lo scarto tiene dentro anche il suo arrotondamento.
const double sogliaMoonTracksMinuti = 1.5;
const double sogliaSwissEphemerisMinuti = 0.5;
const double sogliaFasiMinuti = 0.5;
const double sogliaJ2000Gradi = 0.005;

final Map<String, dynamic> _rif = jsonDecode(
    File('docs/collaudo/FV/fv04_luna_fuori_corso_riferimento.json')
        .readAsStringSync()) as Map<String, dynamic>;

DateTime _utc(String s) => DateTime.parse(s).toUtc();

double _minuti(DateTime a, DateTime b) =>
    (a.difference(b).inMicroseconds / 6e7).abs();

List<IntervalloFuoriCorso> _vuotiDel(DateTime da, DateTime a) =>
    IlMotoreLunare.fuoriCorsoFra(da, a);

/// Il vuoto del motore la cui fine sta piu' vicina a [fine].
IntervalloFuoriCorso _vicino(List<IntervalloFuoriCorso> vuoti, DateTime fine) {
  vuoti.sort((x, y) => _minuti(x.fine, fine).compareTo(_minuti(y.fine, fine)));
  return vuoti.first;
}

void main() {
  test('la Luna fuori corso contro Moon Tracks, ottobre e novembre 2026', () {
    final righe = (_rif['moon_tracks']['intervalli'] as List).cast<Map>();
    cardinaleMinimo(righe.length, 20,
        cosa: 'intervalli di Moon Tracks',
        perche: 'L\'ordine ne pretende almeno venti.');
    final vuoti =
        _vuotiDel(DateTime.utc(2026, 9, 28), DateTime.utc(2026, 12, 3));
    var maxInizio = 0.0, maxFine = 0.0;
    for (final r in righe) {
      final inizio = _utc(r['inizio_utc'] as String);
      final fine = _utc(r['fine_utc'] as String);
      final v = _vicino(vuoti, fine);
      final di = _minuti(v.inizio.toUtc(), inizio);
      final df = _minuti(v.fine.toUtc(), fine);
      if (di > maxInizio) maxInizio = di;
      if (df > maxFine) maxFine = df;
      expect(di, lessThanOrEqualTo(sogliaMoonTracksMinuti),
          reason: 'inizio del vuoto di ${r['inizio_utc']} (${r['aspetto']}): '
              'il motore dice ${v.inizio.toUtc()}');
      expect(df, lessThanOrEqualTo(sogliaMoonTracksMinuti),
          reason: 'fine del vuoto di ${r['fine_utc']}: il motore dice '
              '${v.fine.toUtc()}');
    }
    // ignore: avoid_print
    print('Moon Tracks, ${righe.length} intervalli: scarto massimo '
        'inizio ${maxInizio.toStringAsFixed(2)} min, fine (ingresso) '
        '${maxFine.toStringAsFixed(2)} min');
  });

  test('la Luna fuori corso contro Swiss Ephemeris, tutto il 2026', () {
    final righe =
        (_rif['swiss_ephemeris_classica']['intervalli'] as List).cast<Map>();
    cardinaleMinimo(righe.length, 150, cosa: 'intervalli di Swiss Ephemeris');
    final vuoti =
        _vuotiDel(DateTime.utc(2025, 12, 27), DateTime.utc(2027, 1, 5));
    var maxInizio = 0.0, maxFine = 0.0, confrontati = 0;
    for (final r in righe) {
      final inizio = _utc(r['inizio_utc'] as String);
      final fine = _utc(r['fine_utc'] as String);
      final v = _vicino(vuoti, fine);
      final di = _minuti(v.inizio.toUtc(), inizio);
      final df = _minuti(v.fine.toUtc(), fine);
      if (di > maxInizio) maxInizio = di;
      if (df > maxFine) maxFine = df;
      confrontati++;
      expect(di, lessThanOrEqualTo(sogliaSwissEphemerisMinuti),
          reason: 'inizio del vuoto che finisce il ${r['fine_utc']} '
              '(${r['aspetto']}): Swiss Ephemeris $inizio, il motore '
              '${v.inizio.toUtc()}');
      expect(df, lessThanOrEqualTo(sogliaSwissEphemerisMinuti),
          reason: 'ingresso del ${r['fine_utc']}: il motore '
              '${v.fine.toUtc()}');
    }
    // ignore: avoid_print
    print('Swiss Ephemeris, $confrontati intervalli: scarto massimo inizio '
        '${(maxInizio * 60).toStringAsFixed(1)} s, fine (ingresso) '
        '${(maxFine * 60).toStringAsFixed(1)} s');
  });

  test('gli ingressi nei segni: il segno giusto, nel giorno locale giusto', () {
    final righe = (_rif['moon_tracks']['intervalli'] as List).cast<Map>();
    final ingressi = IlMotoreLunare.ingressiFra(
        DateTime.utc(2026, 9, 28), DateTime.utc(2026, 12, 3));
    for (final r in righe) {
      final fine = _utc(r['fine_utc'] as String);
      final i = ingressi.firstWhere(
          (x) => _minuti(x.istante.toUtc(), fine) <= sogliaMoonTracksMinuti,
          orElse: () => fail('nessun ingresso vicino a ${r['fine_utc']}'));
      expect(i.segno.italianName, r['entra_in'],
          reason: 'ingresso del ${r['fine_utc']}');
      // Il giorno locale che contiene l'ingresso lo riporta, allo stesso
      // istante entro un secondo (le bisezioni partono da griglie diverse),
      // e il giorno dopo no.
      final locale = i.istante.toLocal();
      final g = IlMotoreLunare.delGiorno(locale);
      expect(g.cambiDiSegno, hasLength(1),
          reason: 'il giorno locale ${g.giorno} non riporta l\'ingresso');
      expect(
          _minuti(g.cambiDiSegno.single.istante, i.istante), lessThan(1 / 60));
      expect(g.cambiDiSegno.single.segno, i.segno);
      final dopo = IlMotoreLunare.delGiorno(
          DateTime(locale.year, locale.month, locale.day + 1));
      expect(
          dopo.cambiDiSegno
              .where((c) => _minuti(c.istante, i.istante) < 1)
              .isEmpty,
          isTrue);
    }
  });

  test('i vuoti tagliati sul giorno locale stanno dentro il giorno', () {
    // Marzo e ottobre portano i cambi dell'ora legale in Europa.
    for (final mese in [3, 10, 11]) {
      final giorni = IlMotoreLunare.delMese(2026, mese);
      var pezzi = Duration.zero;
      for (final g in giorni) {
        final dopo = DateTime(g.giorno.year, g.giorno.month, g.giorno.day + 1);
        for (final v in g.fuoriCorso) {
          expect(v.inizio.isBefore(g.giorno), isFalse);
          expect(v.fine.isAfter(dopo), isFalse);
          expect(v.durata, greaterThan(Duration.zero));
          pezzi += v.durata;
        }
      }
      // I pezzi tagliati sommano gli intervalli interi tagliati sul mese.
      final da = giorni.first.giorno;
      final a = DateTime(da.year, da.month + 1);
      var interi = Duration.zero;
      for (final v in IlMotoreLunare.fuoriCorsoFra(da, a)) {
        final i = v.inizio.isBefore(da) ? da : v.inizio;
        final f = v.fine.isAfter(a) ? a : v.fine;
        interi += f.difference(i);
      }
      expect((pezzi - interi).inSeconds.abs(), lessThanOrEqualTo(1),
          reason: 'mese $mese: pezzi $pezzi, interi $interi');
    }
  });

  test('le Lune nuove e piene del 2026 contro Swiss Ephemeris', () {
    final fasi = _rif['swiss_ephemeris_fasi_2026'] as Map;
    final da = DateTime.utc(2026), a = DateTime.utc(2027);
    for (final (chiave, nostre) in [
      ('lune_nuove_utc', IlMotoreLunare.luneNuoveFra(da, a)),
      ('lune_piene_utc', IlMotoreLunare.lunePieneFra(da, a)),
    ]) {
      final loro = (fasi[chiave] as List).cast<String>().map(_utc).toList();
      cardinaleMinimo(loro.length, 12, cosa: chiave);
      expect(nostre.length, loro.length, reason: chiave);
      for (var i = 0; i < loro.length; i++) {
        expect(_minuti(nostre[i].toUtc(), loro[i]),
            lessThanOrEqualTo(sogliaFasiMinuti),
            reason: '$chiave ${loro[i]}: il motore ${nostre[i].toUtc()}');
      }
    }
  });

  test('il giorno lunare: 1 nel giorno della Luna nuova, poi uno al giorno',
      () {
    var visti = 0;
    GiornoLunare? ieri;
    for (var mese = 1; mese <= 12; mese++) {
      for (final g in IlMotoreLunare.delMese(2026, mese)) {
        visti++;
        expect(g.giornoLunare, inInclusiveRange(1, 30));
        if (g.lunaNuova) {
          expect(g.giornoLunare, 1, reason: 'Luna nuova del ${g.giorno}');
        } else if (ieri != null) {
          expect(g.giornoLunare, ieri.giornoLunare + 1,
              reason: 'il giorno lunare del ${g.giorno} non segue quello di '
                  'ieri');
        }
        ieri = g;
      }
    }
    cardinaleMinimo(visti, 365, cosa: 'giorni del 2026');
    // Lune nuove e piene: dodici o tredici l'anno, ognuna in un giorno solo.
    final giorni = [
      for (var m = 1; m <= 12; m++) ...IlMotoreLunare.delMese(2026, m),
    ];
    expect(giorni.where((g) => g.lunaNuova).length, inInclusiveRange(12, 13));
    expect(giorni.where((g) => g.lunaPiena).length, inInclusiveRange(12, 13));
  });

  test('la Luna in J2000 contro Swiss Ephemeris', () {
    final righe =
        (_rif['swiss_ephemeris_luna_j2000']['istanti'] as List).cast<Map>();
    cardinaleMinimo(righe.length, 20, cosa: 'istanti della Luna J2000');
    var massimo = 0.0;
    for (final r in righe) {
      final jd =
          IlCieloDiMeeus.giornoGiuliano(_utc(r['istante_utc'] as String));
      final nostra = IlCieloDiMeeus.longitudineJ2000(CorpoCeleste.luna, jd);
      final loro = (r['longitudine_j2000'] as num).toDouble();
      final d = ((nostra - loro + 540) % 360 - 180).abs();
      if (d > massimo) massimo = d;
      expect(d, lessThanOrEqualTo(sogliaJ2000Gradi),
          reason: 'Luna J2000 a ${r['istante_utc']}');
    }
    // ignore: avoid_print
    print('Luna J2000: scarto massimo ${(massimo * 3600).toStringAsFixed(1)}'
        ' secondi d\'arco su ${righe.length} istanti');
  });

  test('i confini delle costellazioni sono quelli del file dichiarato', () {
    final righe = File('docs/collaudo/FV/fv04_confini_delle_costellazioni.txt')
        .readAsLinesSync()
        .where((r) => r.isNotEmpty && !r.startsWith('#'))
        .map((r) => r.split('\t'))
        .toList();
    cardinaleMinimo(righe.length, 13, cosa: 'confini sull\'eclittica');
    const nostri = IlMotoreLunare.confiniDelleCostellazioni;
    expect(nostri.length, righe.length);
    for (var i = 0; i < righe.length; i++) {
      expect(nostri[i].da, double.parse(righe[i][0]),
          reason: 'confine ${righe[i][1]} -> ${righe[i][2]}');
      expect(nostri[i].iau, righe[i][2]);
    }
  });

  test('il tipo biodinamico cambia esattamente ai confini', () {
    const elementi = {
      'Ari': TipoBiodinamico.frutto,
      'Tau': TipoBiodinamico.radice,
      'Gem': TipoBiodinamico.fiore,
      'Cnc': TipoBiodinamico.foglia,
      'Leo': TipoBiodinamico.frutto,
      'Vir': TipoBiodinamico.radice,
      'Lib': TipoBiodinamico.fiore,
      'Sco': TipoBiodinamico.foglia,
      'Oph': null,
      'Sgr': TipoBiodinamico.frutto,
      'Cap': TipoBiodinamico.radice,
      'Aqr': TipoBiodinamico.fiore,
      'Psc': TipoBiodinamico.foglia,
    };
    const c = IlMotoreLunare.confiniDelleCostellazioni;
    for (var i = 0; i < c.length; i++) {
      final prima = c[(i - 1 + c.length) % c.length];
      expect(IlMotoreLunare.costellazioneDi(c[i].da + 0.001).iau, c[i].iau);
      expect(IlMotoreLunare.costellazioneDi(c[i].da - 0.001).iau, prima.iau);
      expect(
          IlMotoreLunare.tipoDi(
              IlMotoreLunare.costellazioneDi(c[i].da + 0.001).segno),
          elementi[c[i].iau],
          reason: 'tipo di ${c[i].iau}');
    }
    // E sulla Luna vera: l'istante in cui la Luna passa dal Leone alla
    // Vergine IAU, cercato sulla longitudine J2000, separa un giorno frutto
    // da un giorno radice.
    final vergine = c.firstWhere((x) => x.iau == 'Vir').da;
    double f(double jd) =>
        (IlCieloDiMeeus.longitudineJ2000(CorpoCeleste.luna, jd) -
                vergine +
                540) %
            360 -
        180;
    var a = IlCieloDiMeeus.giornoGiuliano(DateTime.utc(2026, 10, 1));
    while (!(f(a) < 0 && f(a + 0.25) >= 0)) {
      a += 0.25;
    }
    var b = a + 0.25;
    while (b - a > 1e-6) {
      final m = (a + b) / 2;
      if (f(m) < 0) {
        a = m;
      } else {
        b = m;
      }
    }
    final istante = IlCieloDiMeeus.istanteDi(a);
    expect(
        IlMotoreLunare.tipoBiodinamicoAllIstante(
            istante.subtract(const Duration(minutes: 5))),
        TipoBiodinamico.frutto);
    expect(
        IlMotoreLunare.tipoBiodinamicoAllIstante(
            istante.add(const Duration(minutes: 5))),
        TipoBiodinamico.radice);
  });

  test('controllo esterno: le larghezze pubblicate dei calendari di Thun', () {
    // Dyyna, "Gardening by the Moon" (https://dyyna.bio/en/magazine/
    // gardening-by-the-moon-lunar-calendar, letta il 15 ottobre 2026), la
    // larghezza in gradi di ogni costellazione nei calendari di Thun, senza
    // fonte dichiarata. Non entra nel codice: e' solo il controllo. Lo
    // Scorpione di Dyyna (25) e' lo Scorpione IAU piu' l'Ofiuco; qui
    // l'Ofiuco resta senza tipo, quindi lo si somma solo per il confronto.
    const dyyna = {
      'Ari': 25, 'Tau': 37, 'Gem': 28, 'Cnc': 20, 'Leo': 36, 'Vir': 44, //
      'Lib': 23, 'Sco': 25, 'Sgr': 33, 'Cap': 28, 'Aqr': 24, 'Psc': 37,
    };
    const c = IlMotoreLunare.confiniDelleCostellazioni;
    final larghezze = <String, double>{};
    for (var i = 0; i < c.length; i++) {
      final fine = c[(i + 1) % c.length].da;
      larghezze[c[i].iau] = (fine - c[i].da) % 360;
    }
    larghezze['Sco'] = larghezze['Sco']! + larghezze.remove('Oph')!;
    for (final e in dyyna.entries) {
      expect((larghezze[e.key]! - e.value).abs(), lessThanOrEqualTo(0.6),
          reason: '${e.key}: IAU ${larghezze[e.key]!.toStringAsFixed(2)}, '
              'Dyyna ${e.value}');
    }
  });

  test('il tempo di calcolo di un mese e di dodici mesi', () {
    final s = Stopwatch()..start();
    IlMotoreLunare.delMese(2026, 10);
    final unMese = s.elapsedMilliseconds;
    s.reset();
    for (var m = 1; m <= 12; m++) {
      IlMotoreLunare.delMese(2027, m);
    }
    final dodici = s.elapsedMilliseconds;
    // ignore: avoid_print
    print('tempo di calcolo: un mese $unMese ms, dodici mesi $dodici ms');
    // Sul telefono si calcola senza rete: un anno intero resta sotto i
    // venti secondi anche su un computer lento.
    expect(dodici, lessThan(20000));
  });

  test('ogni giorno ha un segno coerente con la Luna di mezzogiorno', () {
    for (final g in IlMotoreLunare.delMese(2026, 10)) {
      final mezzogiorno =
          DateTime(g.giorno.year, g.giorno.month, g.giorno.day, 12);
      final lon =
          IlCieloDiMeeus.longitudineAllIstante(CorpoCeleste.luna, mezzogiorno);
      expect(g.segno, Zodiac.values[lon ~/ 30]);
      expect(g.elongazione,
          closeTo(IlMotoreLunare.elongazione(mezzogiorno), 1e-9));
    }
  });
}
