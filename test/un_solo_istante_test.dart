import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/sky.dart';
import 'package:flutter_test/flutter_test.dart';

/// UN SOLO ISTANTE, DICHIARATO.
///
/// **La segnalazione.** Screenshot del fondatore del 1 agosto 2026 alle 18:04,
/// scheda della Bilancia: "12 gradi sopra il suolo, a sud-est". L'Architetto ha
/// calcolato per Milano 29,4 gradi alle 18:04 e 13,0 gradi a mezzanotte, e ne
/// ha dedotto che l'altezza fosse quella della mezzanotte e la direzione quella
/// dell'istante.
///
/// **LA CAUSA ERA UN'ALTRA, e l'ho trovata misurando invece di fidarmi.** Il
/// fuso veniva tolto DUE VOLTE: `buildSkyFor` sottraeva `timeZoneOffset` a
/// mano, ottenendo un DateTime ancora marcato "locale", e poi
/// `Celestial.julianDay` chiamava `toUtc()` e lo toglieva di nuovo. In Italia
/// d'estate sono quattro ore invece di due. Con due ore di troppo indietro, la
/// Bilancia stava davvero a dodici gradi verso sud-est: i due numeri erano
/// coerenti fra loro e sbagliati insieme, non uno di un istante e uno di un
/// altro.
///
/// **La stessa causa spiegava i 123,7 gradi** che stavano aperti in RIPRESA.md:
/// un istante gia' in UTC non veniva toccato, uno civile veniva convertito due
/// volte, quindi i due modi di scrivere lo stesso momento non potevano dare lo
/// stesso cielo. Una causa sola per due difetti che sembravano distinti.
/// **GLI ISTANTI SONO ASSOLUTI, NON L'ORA DELLA MACCHINA. Ordine BZ voce 02.**
///
/// Questa prova nasceva con `DateTime(2026, 8, 1, 18, 4)`, che non e' un
/// istante: e' un orologio da parete, e dice un momento diverso su ogni
/// macchina. Sul PC del fondatore, a Roma, valeva le 16:04 UTC; sul Mac di
/// Codemagic, che gira a UTC, valeva le 18:04 UTC, cioe' due ore di cielo piu'
/// in la': la Bilancia usciva a 35,14 gradi invece di 29,4 e la build dei
/// fondatori non si produceva. **Le due ore erano la differenza fra l'Italia
/// d'agosto e UTC, non un difetto del calcolo.**
///
/// Adesso gli istanti si scrivono in UTC e l'ora civile italiana si dichiara
/// nel commento: 18:04 a Milano il 1 agosto 2026 sono le 16:04 UTC, perche'
/// d'estate l'Italia sta due ore avanti. Il risultato non dipende piu' dal
/// fuso della macchina che lancia la suite.
void main() {
  const milano = BirthPlace(
    label: 'Milano',
    latitude: 45.4642,
    longitude: 9.19,
    timezone: 'Europe/Rome',
  );

  late SkyCatalog catalogo;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    catalogo = await SkyCatalog.load();
  });

  SkyStar bilanciaA(DateTime istante) {
    final cielo = buildSkyFor(catalogo, istante, milano);
    for (final c in cielo.constellations) {
      if (!c.name.toLowerCase().contains('bilanc')) continue;
      final p = puntoDellaFigura(c.stars);
      if (p != null) return p;
    }
    fail('la Bilancia non risulta sopra il suolo a $istante');
  }

  test('Altezza e direzione appartengono allo STESSO istante', () {
    // I numeri dell'Architetto, calcolati in modo indipendente per Milano.
    // Alla mezzanotte fra l'1 e il 2 agosto 2026 la Bilancia sta a circa 13
    // gradi verso SUD-OVEST. Questa prova e' rossa sul codice di prima, dove
    // la direzione rispondeva sud-est: quella era la volta ruotata di due ore
    // in piu' del dovuto.
    // Mezzanotte fra l'1 e il 2 agosto a Milano, cioe' le 22:00 UTC dell'1.
    final b = bilanciaA(DateTime.utc(2026, 8, 1, 22, 0));
    expect(b.altDeg, closeTo(13.0, 1.0),
        reason: 'l\'altezza non e\' quella della mezzanotte dichiarata');
    // Sud-ovest: azimut fra 180 e 270, contato da nord verso est.
    expect(b.azDeg, greaterThan(180),
        reason: 'la direzione non e\' a ovest del meridiano, quindi non e\' '
            'quella della mezzanotte: e\' di un altro istante');
    expect(b.azDeg, lessThan(270));
    expect(b.azDeg, closeTo(241.8, 3.0));
  });

  test('E alle 18:04 sono i numeri delle 18:04, non altri', () {
    // L'altro capo della verifica: se il fuso torna a essere tolto due volte,
    // questa cade insieme all'altra.
    // Le 18:04 di Milano, cioe' le 16:04 UTC.
    final b = bilanciaA(DateTime.utc(2026, 8, 1, 16, 4));
    expect(b.altDeg, closeTo(29.4, 1.0));
    expect(b.azDeg, closeTo(147.0, 3.0),
        reason: 'a sud-est, come dice il calcolo indipendente');
  });

  test('Lo stesso istante scritto nei due modi da\' lo stesso cielo', () {
    // I 123,7 GRADI, chiusi. Un'ora civile e la sua UTC sono lo stesso
    // momento: se i due cieli non coincidono, uno dei due e' sbagliato.
    // **L'ISTANTE E' UNO SOLO E SI PARTE DA QUELLO ASSOLUTO**: prima qui
    // c'era un orario da parete, e su una macchina a UTC le due scritture
    // erano lo stesso oggetto, cioe' la prova non confrontava piu' niente.
    final assoluto = DateTime.utc(2026, 8, 1, 16, 4);
    final civile = assoluto.toLocal();
    final a = bilanciaA(civile);
    final b = bilanciaA(assoluto);
    expect((a.azDeg - b.azDeg).abs(), lessThan(0.01),
        reason: 'lo stesso istante produce due cieli diversi: il fuso viene '
            'applicato una volta di troppo da qualche parte');
    expect((a.altDeg - b.altDeg).abs(), lessThan(0.01));
  });

  test('L\'istante della schermata e\' la notte che viene, e si legge', () {
    // L'istante e' un DATO, non una deduzione ripetuta in tre punti.
    expect(mezzanotteDellaNotteCheViene(DateTime(2026, 8, 1, 18, 4)),
        DateTime(2026, 8, 2),
        reason: 'di sera la notte che viene e\' quella che deve arrivare');
    expect(mezzanotteDellaNotteCheViene(DateTime(2026, 8, 2, 2, 30)),
        DateTime(2026, 8, 2),
        reason: 'alle due di notte la notte che viene e\' quella in corso, '
            'non quella di domani');
    expect(mezzanotteDellaNotteCheViene(DateTime(2026, 8, 2, 11, 59)),
        DateTime(2026, 8, 2));
    expect(mezzanotteDellaNotteCheViene(DateTime(2026, 8, 2, 12, 0)),
        DateTime(2026, 8, 3));
  });

  test('Il punto della figura e\' dichiarato, ed e\' uno solo', () {
    // Le stelle della Bilancia stanno fra 0,8 e 13 gradi ALLO STESSO ISTANTE:
    // dire "13 gradi" senza dire di cosa non e' un dato, e' un numero.
    final cielo =
        buildSkyFor(catalogo, DateTime.utc(2026, 8, 1, 22, 0), milano);
    for (final c in cielo.constellations) {
      if (!c.name.toLowerCase().contains('bilanc')) continue;
      final alte =
          c.stars.where((s) => s.altDeg > kAltezzaOrizzonte).toList();
      final scelto = puntoDellaFigura(c.stars)!;
      for (final s in alte) {
        expect(s.mag, greaterThanOrEqualTo(scelto.mag),
            reason: 'il punto scelto non e\' la stella piu\' luminosa');
      }
      final altezze = alte.map((s) => s.altDeg).toList()..sort();
      expect(altezze.last - altezze.first, greaterThan(5),
          reason: 'se le stelle fossero tutte alla stessa altezza questa '
              'dichiarazione non servirebbe, e la prova andrebbe tolta');
    }
  });

  test('Nessun testo della schermata nomina il presente', () {
    // La seconda prova che l'ordine chiede: i testi si adeguano all'istante.
    // Vale per la riga del calcolo come per la nota in fondo, ed e' gia'
    // successo di correggerne una e lasciare l'altra al presente.
    const sospette = ['adesso', 'in questo momento', 'ora sta', 'sta ora'];
    final colpevoli = <String>[];
    for (final percorso in const [
      'lib/features/santuario/sky_overview_screen.dart',
      'lib/features/santuario/sky_postcard.dart',
    ]) {
      final righe = File(percorso).readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        if (r.trimLeft().startsWith('//')) continue;
        // Solo le stringhe mostrate, non le chiavi ne' i percorsi. NON si
        // filtra per "deve avere uno spazio": l'avverbio del punto solo e' la
        // parola "Adesso" da sola, e con quel filtro questa prova restava
        // verde proprio sul testo che doveva denunciare. L'ho vista passare
        // sul codice di prima e l'ho riscritta.
        for (final m in RegExp(r"'((?:[^'\\]|\\.)*)'").allMatches(r)) {
          final t = (m.group(1) ?? '').toLowerCase();
          if (t.contains('/') || t.contains('_')) continue;
          for (final s in sospette) {
            if (t.contains(s)) colpevoli.add('$percorso riga ${i + 1}: $t');
          }
        }
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'questi testi nominano il presente mentre l\'istante di '
            'riferimento e\' la notte: $colpevoli');
  });
}
