import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/services/free_astro_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CARTA NATALE CONTRO SWISS EPHEMERIS, SU TRE NASCITE E SU TUTTO.
///
/// Ordine 2170, voce 3. Il giro scorso di nascite ne era stata verificata una
/// sola, e non per scelta: le altre due risposte del motore non esistevano nel
/// repository. Adesso esistono, catturate chiamando la callable `natalChart`
/// dal PC, e le nascite sono tre come erano state ordinate.
///
/// **LA FONTE E' SWISS EPHEMERIS**, la libreria di Astrodienst, interrogata il
/// 10 agosto 2026 con `tool/riferimento_carta.py`. Quel generatore si controlla
/// da solo prima di essere creduto: sul caso di Roma riproduce i numeri presi a
/// monte con pyswisseph su tutte e ventisette le quantita', con scarto massimo
/// 0,000088 gradi. I numeri qui sotto sono inchiodati: nessuna rete a tempo di
/// prova, nessun ricalcolo.
///
/// **SI CONFRONTA TUTTO**, non solo gli angoli: dodici corpi, Ascendente,
/// Medio Cielo e tutte e dodici le cuspidi Placidus. Le divergenze di 0,09-0,42
/// gradi che il giro scorso restavano aperte sulle cuspidi erano
/// dell'iterazione scritta a mano, non del motore: quell'iterazione e' stata
/// buttata e non va rifatta.
///
/// **CHIRONE NON E' VERIFICATO, e si dichiara.** Swiss Ephemeris in modalita'
/// Moshier non lo produce, perche' e' un asteroide e non un pianeta dei
/// polinomi analitici. La carta del motore lo porta, e resta senza riscontro:
/// e' l'unico dei tredici corpi in questa condizione.
void main() {
  /// Tolleranza in gradi. Quattro volte l'arrotondamento misurato sui numeri
  /// del motore, che ha tre decimali: piu' stretta di cosi' misurerebbe la
  /// virgola, piu' larga nasconderebbe un peggioramento vero.
  ///
  /// **LA DIFFERENZA SULLA LUNA NON ERA UN TRONCAMENTO, e la ragione giusta
  /// va scritta anche se l'azione sarebbe stata la stessa.** Il giro scorso il
  /// generatore dava 345,636488 dove l'ordine 2170 riportava 345,6364, e
  /// l'avevo attribuito a un arrotondamento per troncamento. Non lo era: sono
  /// **tre decimi di secondo d'arco** fra due modalita' dello stesso Swiss
  /// Ephemeris, quella analitica di Moshier che questo generatore usa e quella
  /// coi file di effemeridi con cui erano stati presi i numeri a monte. Le due
  /// modalita' divergono di quell'ordine di grandezza sulla Luna, che e' il
  /// corpo piu' veloce e piu' sensibile alle perturbazioni.
  ///
  /// Contava saperlo: un troncamento non peggiora mai, una differenza di
  /// modello puo' crescere su altri corpi o altre epoche. Qui resta cento
  /// volte sotto la tolleranza, e il confronto con JPL Horizons dice che la
  /// modalita' Moshier e' la piu' vicina al cielo vero delle due.
  const tolleranza = 0.002;

  double scarto(double a, double b) {
    final d = (a - b).abs() % 360.0;
    return d > 180.0 ? 360.0 - d : d;
  }

  /// Una nascita da verificare: la risposta conservata del motore e i numeri
  /// che Swiss Ephemeris da' per lo stesso istante.
  const nascite = <_Nascita>[
    _Nascita(
      nome: 'Roma, 15 giugno 1990, 12:30 UTC',
      fixture: 'assets/data/sample_natal_rome.json',
      quando: (1990, 6, 15, 12, 30),
      dove: (41.9028, 12.4964),
      corpi: {
        'sun': 84.149453,
        'moon': 345.636487,
        'mercury': 65.726460,
        'venus': 48.802098,
        'mars': 11.056288,
        'jupiter': 105.894000,
        'saturn': 294.030713,
        'uranus': 278.164401,
        'neptune': 283.716556,
        'pluto': 225.401082,
        'north_node': 309.696780,
        'lilith': 234.953661,
        // Chirone da JPL HORIZONS, corpo minore 2060, non da Swiss Ephemeris:
        // in modalita' Moshier non si calcola, e il file di effemeridi degli
        // asteroidi non entra in questo repository.
        'chiron': 106.062613,
      },
      asc: 190.608279,
      mc: 102.448147,
      cuspidi: [
        190.608279, 217.293040, 248.305300, 282.448147, 316.048689, 345.768725,
        10.608279, 37.293040, 68.305300, 102.448147, 136.048689, 165.768725,
      ],
    ),
    // EMISFERO AUSTRALE, latitudine negativa: le case si dispongono
    // dall'altra parte, ed e' il caso in cui una formula sbagliata di segno
    // resterebbe invisibile guardando solo l'Europa.
    _Nascita(
      nome: 'Sydney, 7 marzo 1972, 18:15 UTC',
      fixture: 'test/fixtures/sample_natal_sydney.json',
      quando: (1972, 3, 7, 18, 15),
      dove: (-33.8688, 151.2093),
      corpi: {
        'sun': 347.284082,
        'moon': 251.326931,
        'mercury': 3.421610,
        'venus': 30.699687,
        'mars': 47.262049,
        'jupiter': 274.890158,
        'saturn': 60.790390,
        'uranus': 197.474076,
        'neptune': 245.255817,
        'pluto': 181.074657,
        'north_node': 303.098220,
        'lilith': 211.407633,
        'chiron': 11.776418, // JPL Horizons, 2060 Chiron
      },
      asc: 326.893517,
      mc: 232.917528,
      cuspidi: [
        326.893517, 351.350174, 20.282938, 52.917528, 86.462348, 118.127415,
        146.893517, 171.350174, 200.282938, 232.917528, 266.462348, 298.127415,
      ],
    ),
    // ALTA LATITUDINE, dove Placidus va in sofferenza: sopra il circolo
    // polare le case si deformano fino a rompersi, e a 64 gradi si e' gia'
    // vicini al punto in cui i conti diventano delicati.
    _Nascita(
      nome: 'Reykjavik, 21 dicembre 1985, 23:50 UTC',
      fixture: 'test/fixtures/sample_natal_reykjavik.json',
      quando: (1985, 12, 21, 23, 50),
      dove: (64.1466, -21.9426),
      corpi: {
        'sun': 270.072373,
        'moon': 32.043524,
        'mercury': 249.299724,
        'venus': 263.212698,
        'mars': 214.436837,
        'jupiter': 316.182993,
        'saturn': 244.079377,
        'uranus': 258.907055,
        'neptune': 273.207976,
        'pluto': 216.661100,
        'north_node': 36.350726,
        'lilith': 52.511621,
        'chiron': 70.942283, // JPL Horizons, 2060 Chiron
      },
      asc: 166.251042,
      mc: 67.822830,
      cuspidi: [
        166.251042, 184.125485, 209.902537, 247.822830, 292.470327, 323.717760,
        346.251042, 4.125485, 29.902537, 67.822830, 112.470327, 143.717760,
      ],
    ),
  ];

  /// La carta come la ottiene l'app: la risposta conservata, interpretata
  /// dallo stesso codice che gira sul telefono.
  NatalChart cartaDellApp(_Nascita n) {
    final grezza =
        jsonDecode(File(n.fixture).readAsStringSync()) as Map<String, dynamic>;
    final (anno, mese, giorno, ora, minuto) = n.quando;
    final (lat, lon) = n.dove;
    return FreeAstroClient().parseResponse(
      grezza,
      BirthDetails(
        date: DateTime(anno, mese, giorno),
        time: TimeOfDay(hour: ora, minute: minuto),
        place: BirthPlace(
          latitude: lat,
          longitude: lon,
          timezone: 'UTC',
          label: n.nome,
        ),
      ),
    );
  }

  test('OGNI nascita porta tutte le quantita\' che le servono', () {
    // **NON UN ELENCO SCRITTO A MANO.** Il giro scorso gli angoli di Sydney
    // c'erano ed erano giusti, ma nel rapporto sono finiti come non
    // confrontati: bastava una svista di chi scriveva per far sembrare
    // scoperta una parte che era coperta. Adesso e' il conto a dirlo, e se
    // domani una nascita nasce senza ASC, senza MC o con undici cuspidi,
    // questa prova cade prima di ogni altra.
    const corpiAttesi = 13; // dodici piu' Chirone
    for (final n in nascite) {
      expect(n.corpi.length, corpiAttesi,
          reason: '${n.nome} porta ${n.corpi.length} corpi invece di '
              '$corpiAttesi: manca il riferimento per '
              '${n.corpi.keys.join(", ")}');
      expect(n.cuspidi.length, 12,
          reason: '${n.nome} porta ${n.cuspidi.length} cuspidi invece di 12');
      expect(n.asc, isNot(0), reason: '${n.nome} non porta l\'Ascendente');
      expect(n.mc, isNot(0), reason: '${n.nome} non porta il Medio Cielo');
    }
    // E le tre nascite ci sono tutte e tre: il campione ordinato e' tre.
    expect(nascite, hasLength(3));
  });

  for (final n in nascite) {
    group(n.nome, () {
      test('i TREDICI corpi combaciano con la fonte terza', () {
        final carta = cartaDellApp(n);
        final nostri = {
          for (final p in carta.planets) p.id: p.longitude,
        };
        final fuori = <String>[];
        var peggiore = 0.0;
        var peggioreNome = '';
        n.corpi.forEach((id, atteso) {
          final nostro = nostri[id];
          expect(nostro, isNotNull,
              reason: 'la carta di ${n.nome} non porta $id: un corpo sparito '
                  'e\' un difetto anche se tutti gli altri sono giusti');
          final s = scarto(nostro!, atteso);
          if (s > peggiore) {
            peggiore = s;
            peggioreNome = id;
          }
          // ignore: avoid_print
          print('CARTA ${n.breve} ${id.padRight(11)} app '
              '${nostro.toStringAsFixed(4)}  Swiss '
              '${atteso.toStringAsFixed(4)}  scarto ${s.toStringAsFixed(5)}');
          if (s > tolleranza) {
            fuori.add('${n.nome}, $id: scarto ${s.toStringAsFixed(5)} gradi '
                'contro una tolleranza di $tolleranza');
          }
        });
        // ignore: avoid_print
        print('CARTA ${n.breve}: scarto massimo sui corpi '
            '${peggiore.toStringAsFixed(5)} su $peggioreNome');
        expect(fuori, isEmpty, reason: fuori.join('\n'));

      });

      test('Ascendente e Medio Cielo combaciano', () {
        final carta = cartaDellApp(n);
        expect(carta.ascendantLongitude, isNotNull,
            reason: 'la carta non porta l\'Ascendente');
        expect(carta.midheavenLongitude, isNotNull,
            reason: 'la carta non porta il Medio Cielo');
        final sAsc = scarto(carta.ascendantLongitude!, n.asc);
        final sMc = scarto(carta.midheavenLongitude!, n.mc);
        // ignore: avoid_print
        print('ANGOLI ${n.breve} ASC app '
            '${carta.ascendantLongitude!.toStringAsFixed(4)}  Swiss '
            '${n.asc.toStringAsFixed(4)}  scarto ${sAsc.toStringAsFixed(5)}');
        // ignore: avoid_print
        print('ANGOLI ${n.breve} MC  app '
            '${carta.midheavenLongitude!.toStringAsFixed(4)}  Swiss '
            '${n.mc.toStringAsFixed(4)}  scarto ${sMc.toStringAsFixed(5)}');
        expect(sAsc, lessThan(tolleranza),
            reason: '${n.nome}: l\'Ascendente scarta di '
                '${sAsc.toStringAsFixed(5)} gradi');
        expect(sMc, lessThan(tolleranza),
            reason: '${n.nome}: il Medio Cielo scarta di '
                '${sMc.toStringAsFixed(5)} gradi');
      });

      test('TUTTE E DODICI le cuspidi Placidus combaciano', () {
        // **E' la parte che il giro scorso era rimasta aperta.** Confrontare
        // i soli angoli lascia fuori otto cuspidi su dodici, cioe' la meta'
        // della ruota che la persona vede.
        final carta = cartaDellApp(n);
        expect(carta.houses, hasLength(12),
            reason: '${n.nome}: la carta porta ${carta.houses.length} cuspidi '
                'invece di dodici');
        final fuori = <String>[];
        var peggiore = 0.0;
        var peggioreCasa = 0;
        for (var i = 1; i <= 12; i++) {
          final nostra =
              carta.houses.firstWhere((h) => h.number == i).longitude;
          final attesa = n.cuspidi[i - 1];
          final s = scarto(nostra, attesa);
          if (s > peggiore) {
            peggiore = s;
            peggioreCasa = i;
          }
          if (s > tolleranza) {
            fuori.add('${n.nome}, cuspide $i: scarto '
                '${s.toStringAsFixed(5)} gradi contro $tolleranza');
          }
        }
        // ignore: avoid_print
        print('CUSPIDI ${n.breve}: scarto massimo '
            '${peggiore.toStringAsFixed(5)} gradi sulla casa $peggioreCasa');
        expect(fuori, isEmpty, reason: fuori.join('\n'));
      });

      test('il sistema di case della risposta e\' quello atteso', () {
        // Se il fornitore cambiasse default, le cuspidi qui sopra
        // cambierebbero tutte insieme e il confronto direbbe "sbagliate"
        // senza dire perche'. Questa prova nomina la causa.
        final grezza = jsonDecode(File(n.fixture).readAsStringSync())
            as Map<String, dynamic>;
        final impostazioni = (grezza['subject']
            as Map<String, dynamic>)['settings'] as Map<String, dynamic>;
        expect(impostazioni['house_system'], 'placidus',
            reason: '${n.nome}: il motore ha risposto col sistema '
                '${impostazioni['house_system']}, e le cuspidi non sono piu\' '
                'confrontabili con un riferimento Placidus');
      });
    });
  }
}

class _Nascita {
  const _Nascita({
    required this.nome,
    required this.fixture,
    required this.quando,
    required this.dove,
    required this.corpi,
    required this.asc,
    required this.mc,
    required this.cuspidi,
  });

  final String nome;
  final String fixture;

  /// Anno, mese, giorno, ora e minuto, in UTC.
  final (int, int, int, int, int) quando;

  /// Latitudine e longitudine.
  final (double, double) dove;

  final Map<String, double> corpi;
  final double asc;
  final double mc;
  final List<double> cuspidi;

  /// Il nome corto, per le righe stampate.
  String get breve => nome.split(',').first.toUpperCase().padRight(10);
}
