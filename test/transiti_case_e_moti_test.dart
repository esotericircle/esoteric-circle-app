import 'dart:io';

import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/transiti_del_giorno.dart';
import 'package:esoteric_circle/core/astro/transiti_nelle_case.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Cuspidi DISUGUALI, come le fa una domificazione per tempo: chi le
  /// credesse larghe trenta gradi ciascuna sbaglierebbe casa.
  const cuspidi = <HouseCusp>[
    HouseCusp(number: 1, longitude: 10.0),
    HouseCusp(number: 2, longitude: 50.0),
    HouseCusp(number: 3, longitude: 75.0),
    HouseCusp(number: 4, longitude: 95.0),
    HouseCusp(number: 5, longitude: 120.0),
    HouseCusp(number: 6, longitude: 155.0),
    HouseCusp(number: 7, longitude: 190.0),
    HouseCusp(number: 8, longitude: 230.0),
    HouseCusp(number: 9, longitude: 255.0),
    HouseCusp(number: 10, longitude: 275.0),
    HouseCusp(number: 11, longitude: 300.0),
    HouseCusp(number: 12, longitude: 335.0),
  ];

  NatalChart carta({bool conCase = true, bool conOra = true}) => NatalChart(
        sunSign: Zodiac.aries,
        hasTime: conOra,
        ascendantLongitude: conOra ? 10.0 : null,
        houses: conCase ? cuspidi : const [],
        planets: [
          const PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: 15.0,
              sign: Zodiac.aries),
        ],
      );

  group('I transiti nelle case natali', () {
    test('una longitudine cade nella casa giusta, anche disuguale', () {
      expect(TransitiNelleCase.casaDi(12.0, cuspidi), 1);
      expect(TransitiNelleCase.casaDi(49.9, cuspidi), 1);
      expect(TransitiNelleCase.casaDi(50.0, cuspidi), 2);
      expect(TransitiNelleCase.casaDi(76.0, cuspidi), 3);
      // La settima, quella della frase che l'ordine cita.
      expect(TransitiNelleCase.casaDi(200.0, cuspidi), 7);
      expect(TransitiNelleCase.casaDi(229.9, cuspidi), 7);
    });

    test('la dodicesima scavalca lo zero dell\'Ariete', () {
      expect(TransitiNelleCase.casaDi(340.0, cuspidi), 12);
      expect(TransitiNelleCase.casaDi(359.9, cuspidi), 12);
      expect(TransitiNelleCase.casaDi(0.0, cuspidi), 12);
      expect(TransitiNelleCase.casaDi(9.9, cuspidi), 12);
    });

    test('ogni grado del giro sta in una casa e in una sola', () {
      for (var g = 0; g < 3600; g++) {
        final casa = TransitiNelleCase.casaDi(g / 10.0, cuspidi);
        expect(casa, isNotNull,
            reason: 'il grado ${g / 10} non sta in nessuna');
        expect(casa, inInclusiveRange(1, 12));
      }
    });

    test('senza cuspidi non si inventa nessuna casa', () {
      expect(TransitiNelleCase.casaDi(100.0, const []), isNull);
      expect(
        TransitiNelleCase.perIlGiorno(
            adesso: DateTime(2026, 8, 4), carta: carta(conCase: false)),
        isEmpty,
      );
      expect(
        TransitiNelleCase.perIlGiorno(
            adesso: DateTime(2026, 8, 4), carta: null),
        isEmpty,
      );
      expect(
        TransitiNelleCase.perIlGiorno(
          adesso: DateTime(2026, 8, 4),
          carta: NatalChart.essential(sunSign: Zodiac.leo, hasTime: false),
        ),
        isEmpty,
      );
    });

    test('cuspidi incomplete non producono case a caso', () {
      expect(
          TransitiNelleCase.casaDi(100.0, cuspidi.take(11).toList()), isNull);
    });

    test('col cielo vero ogni corpo ha la sua casa', () {
      final case_ = TransitiNelleCase.perIlGiorno(
          adesso: DateTime(2026, 8, 4), carta: carta());
      expect(case_.keys.toSet(), CorpoCeleste.values.toSet());
      for (final c in case_.values) {
        expect(c, inInclusiveRange(1, 12));
      }
    });
  });

  group('I moti retrogradi', () {
    test('il Sole e la Luna non retrogradano mai', () {
      // Non e' una convenzione: la loro longitudine geocentrica cresce sempre.
      for (var g = 0; g < 800; g += 3) {
        final jd = TransitiDelGiorno.giornoGiulianoDi(
            DateTime(2026, 1, 1).add(Duration(days: g)));
        expect(Effemeridi.retrogrado(CorpoCeleste.sole, jd), isFalse);
        expect(Effemeridi.retrogrado(CorpoCeleste.luna, jd), isFalse);
      }
    });

    test('Mercurio retrograda quanto dice il libro, tre volte l\'anno', () {
      // Mercurio retrograda tre o quattro volte l'anno per circa tre settimane:
      // sono fra i cinquanta e i settantacinque giorni l'anno. Se il motore
      // dicesse zero, o meta' anno, sarebbe rotto.
      var giorni = 0;
      for (var g = 0; g < 365; g++) {
        final jd = TransitiDelGiorno.giornoGiulianoDi(
            DateTime(2026, 1, 1).add(Duration(days: g)));
        if (Effemeridi.retrogrado(CorpoCeleste.mercurio, jd)) giorni++;
      }
      expect(giorni, inInclusiveRange(45, 80),
          reason: 'Mercurio retrogrado $giorni giorni nel 2026');
    });

    test('i lenti retrogradano circa cinque mesi l\'anno', () {
      // I pianeti esterni sono retrogradi grosso modo per il tempo in cui la
      // Terra li scavalca, cioe' circa cinque mesi l'anno per i piu' lontani.
      for (final corpo in [
        CorpoCeleste.urano,
        CorpoCeleste.nettuno,
        CorpoCeleste.plutone
      ]) {
        var giorni = 0;
        for (var g = 0; g < 365; g++) {
          final jd = TransitiDelGiorno.giornoGiulianoDi(
              DateTime(2026, 1, 1).add(Duration(days: g)));
          if (Effemeridi.retrogrado(corpo, jd)) giorni++;
        }
        expect(giorni, inInclusiveRange(120, 190),
            reason: '${corpo.nome} retrogrado $giorni giorni nel 2026');
      }
    });

    test('il retrogrado si misura, non si legge da una tabella', () {
      // Se qualcuno sostituisse il calcolo con un elenco fisso, la velocita'
      // non tornerebbe piu' col segno del retrogrado.
      for (final corpo in CorpoCeleste.values) {
        for (var g = 0; g < 400; g += 17) {
          final jd = TransitiDelGiorno.giornoGiulianoDi(
              DateTime(2026, 1, 1).add(Duration(days: g)));
          expect(Effemeridi.retrogrado(corpo, jd),
              Effemeridi.velocitaGiornaliera(corpo, jd) < 0);
        }
      }
    });

    test('l\'elenco dei retrogradi del giorno non contiene i luminari', () {
      final r = AspettiDiOggi.retrogradiDelGiorno(DateTime(2026, 8, 4));
      expect(r.contains(CorpoCeleste.sole), isFalse);
      expect(r.contains(CorpoCeleste.luna), isFalse);
    });
  });

  group('Aspetti applicativi o separativi', () {
    test('un aspetto sa dire se si sta formando o sciogliendo', () {
      final oggi = AspettiDiOggi.perIlGiorno(
          adesso: DateTime(2026, 8, 4), carta: carta());
      expect(oggi, isNotEmpty);
      for (final a in oggi) {
        expect(a.applicativo, isNotNull,
            reason: 'un aspetto del giorno non sa se sta arrivando o passando');
      }
    });

    test('applicativo vuol dire che domani l\'orbo e\' piu\' stretto', () {
      final quando = DateTime(2026, 8, 4);
      final mia = carta();
      final oggi = AspettiDiOggi.perIlGiorno(adesso: quando, carta: mia);
      final domani =
          TransitiDelGiorno.posizioni(quando.add(const Duration(days: 1)));

      for (final a in oggi) {
        final corpo = CorpoCeleste.values.firstWhere((c) => c.id == a.aId);
        final orboDomani = ChartAspect(
          aLongitude: domani[corpo]!,
          bLongitude: a.bLongitude,
          type: a.type,
        ).orbe;
        expect(a.applicativo, orboDomani < a.orbe,
            reason: '${corpo.nome} ${a.type.italianName}: oggi ${a.orbe}, '
                'domani $orboDomani');
      }
    });

    test('senza il domani non si finge di saperlo', () {
      final senza = AspettiDiOggi.fra(
        transiti: TransitiDelGiorno.posizioni(DateTime(2026, 8, 4)),
        carta: carta(),
      );
      expect(senza, isNotEmpty);
      for (final a in senza) {
        expect(a.applicativo, isNull);
      }
    });
  });

  group('Il limite dichiarato sul giorno esatto', () {
    test('ogni corpo sa dire di quanti giorni e\' incerto', () {
      final jd = TransitiDelGiorno.giornoGiulianoDi(DateTime(2026, 8, 4));
      for (final corpo in CorpoCeleste.values) {
        expect(Effemeridi.scartoMisurato[corpo], isNotNull,
            reason: '${corpo.nome} non dichiara il suo scarto misurato');
        expect(Effemeridi.giorniDiIncertezza(corpo, jd), greaterThan(0));
      }
    });

    test('Saturno e\' incerto di giorni, non di ore', () {
      // Il numero che l'ordine chiede di dichiarare: 0,1414 gradi di scarto su
      // un pianeta che fa circa 0,03 gradi al giorno sono giorni, non ore.
      final jd = TransitiDelGiorno.giornoGiulianoDi(DateTime(2026, 8, 4));
      final giorni = Effemeridi.giorniDiIncertezza(CorpoCeleste.saturno, jd);
      expect(giorni, greaterThan(1.0),
          reason: 'se fosse sotto il giorno, un testo potrebbe dire "esatto '
              'oggi", e non puo\'');
    });

    test('lo scarto dichiarato copre tutti i corpi consegnati', () {
      expect(
          Effemeridi.scartoMisurato.keys.toSet(), CorpoCeleste.values.toSet());
    });
  });

  group('La porta della card condivisa e\' chiusa', () {
    test('la card non rilegge piu\' il corpus per conto suo', () {
      final testo = File('lib/features/horoscope/oroscopo_share_card.dart')
          .readAsStringSync();
      expect(testo.contains('HoroscopeData'), isFalse,
          reason: 'la card da condividere e\' tornata a leggersi il corpus');
    });
  });
}
