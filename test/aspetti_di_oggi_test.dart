import 'dart:io';

import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/transiti_del_giorno.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE SEI PROVE DEL ROSSO DELLA VOCE 2, piu' l'enumerazione delle porte.
void main() {
  /// Una carta natale finta ma ben formata, con longitudini scelte a mano.
  NatalChart carta({
    double sole = 10.0,
    double luna = 100.0,
    double marte = 200.0,
    double? ascendente,
  }) =>
      NatalChart(
        sunSign: Zodiac.aries,
        hasTime: ascendente != null,
        ascendantLongitude: ascendente,
        planets: [
          PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: sole,
              sign: Zodiac.aries),
          PlanetPosition(
              id: 'moon',
              name: 'Luna',
              glyph: '☽',
              longitude: luna,
              sign: Zodiac.cancer),
          PlanetPosition(
              id: 'mars',
              name: 'Marte',
              glyph: '♂',
              longitude: marte,
              sign: Zodiac.libra),
        ],
      );

  group('Un modello solo per gli aspetti', () {
    test('ChartAspect e AspectType sono definiti una volta sola', () {
      // Si contano le DEFINIZIONI, non i file che ne contengono almeno una:
      // la prima stesura contava i file, e due modelli scritti nello stesso
      // file le passavano sotto il naso. L'ha trovata la mutazione.
      final aspetto = <String>[];
      final tipo = <String>[];
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final testo = f.readAsStringSync();
        final percorso = f.path.replaceAll(r'\', '/');
        for (final m
            in RegExp(r'class\s+(\w*ChartAspect)\b').allMatches(testo)) {
          aspetto.add('$percorso: ${m.group(1)}');
        }
        for (final m
            in RegExp(r'enum\s+(\w*AspectType)\b').allMatches(testo)) {
          tipo.add('$percorso: ${m.group(1)}');
        }
      }
      expect(aspetto, hasLength(1), reason: 'un secondo modello: $aspetto');
      expect(tipo, hasLength(1), reason: 'un secondo tipo: $tipo');
    });

    test('gli aspetti dei transiti usano quel modello, non un altro', () {
      final oggi = AspettiDiOggi.fra(
        transiti: {CorpoCeleste.sole: 10.0},
        carta: carta(),
      );
      expect(oggi.first, isA<ChartAspect>());
    });
  });

  group('Nessun orbo senza fonte', () {
    test('ogni angolo e ogni orbo ha la sua citazione accanto', () {
      final modello = File('lib/core/astro/natal_chart.dart').readAsStringSync();
      // Gli angoli sono tolemaici e la fonte va nominata dove stanno.
      expect(modello, contains('Tetrabiblos'),
          reason: 'gli angoli degli aspetti non citano Tolomeo');

      final motore =
          File('lib/core/astro/aspetti_di_oggi.dart').readAsStringSync();
      final blocco = motore.substring(0, motore.indexOf('orboBase'));
      // Non basta che ci sia una fonte da qualche parte: deve stare PRIMA dei
      // numeri, cioe' accanto a loro, dove la legge chi li cambia.
      for (final atteso in ['fonti', 'diverge', 'scelta del progetto']) {
        expect(blocco.toLowerCase(), contains(atteso.toLowerCase()),
            reason: 'il blocco degli orbi non dichiara "$atteso"');
      }
    });

    test('la Luna in transito ha l\'orbo piu\' stretto, come dicono le fonti',
        () {
      for (final tipo in AspectType.values) {
        expect(AspettiDiOggi.orboPer(CorpoCeleste.luna, tipo),
            lessThan(AspettiDiOggi.orboBase[tipo]! + 0.001));
        expect(AspettiDiOggi.orboPer(CorpoCeleste.luna, tipo),
            lessThanOrEqualTo(AspettiDiOggi.orboLunaInTransito));
      }
      expect(AspettiDiOggi.orboPer(CorpoCeleste.saturno, AspectType.trine),
          AspettiDiOggi.orboBase[AspectType.trine]);
    });
  });

  group('Nessuna rete, nessun costo', () {
    test('gli aspetti si calcolano senza toccare niente di fuori', () {
      // Nessun binding di Flutter inizializzato, nessuna finta di rete: se
      // servisse una chiamata, qui salterebbe.
      final oggi = AspettiDiOggi.perIlGiorno(
        adesso: DateTime(2026, 8, 4, 9),
        carta: carta(ascendente: 250.0),
      );
      expect(oggi, isA<List<ChartAspect>>());
    });
  });

  group('L\'elenco dipende davvero dalla persona e dal giorno', () {
    test('cambiando la carta natale cambia l\'elenco', () {
      final transiti = TransitiDelGiorno.posizioni(DateTime(2026, 8, 4));
      final una = AspettiDiOggi.fra(transiti: transiti, carta: carta());
      final altra = AspettiDiOggi.fra(
        transiti: transiti,
        carta: carta(sole: 47.0, luna: 213.0, marte: 311.0),
      );
      expect(_firma(una), isNot(_firma(altra)),
          reason: 'due persone diverse ricevono gli stessi aspetti');
    });

    test('cambiando il giorno cambia l\'elenco', () {
      final mia = carta(ascendente: 250.0);
      final oggi = AspettiDiOggi.perIlGiorno(
          adesso: DateTime(2026, 8, 4), carta: mia);
      final fraUnMese = AspettiDiOggi.perIlGiorno(
          adesso: DateTime(2026, 9, 4), carta: mia);
      expect(_firma(oggi), isNot(_firma(fraUnMese)),
          reason: 'un mese dopo il cielo e\' lo stesso');
    });

    test('nello stesso giorno l\'elenco non si muove', () {
      final mia = carta(ascendente: 250.0);
      expect(
        _firma(AspettiDiOggi.perIlGiorno(
            adesso: DateTime(2026, 8, 4, 7, 30), carta: mia)),
        _firma(AspettiDiOggi.perIlGiorno(
            adesso: DateTime(2026, 8, 4, 22, 45), carta: mia)),
      );
    });

    test('l\'elenco e\' ordinato dal piu\' stretto al piu\' largo', () {
      final oggi = AspettiDiOggi.perIlGiorno(
          adesso: DateTime(2026, 8, 4), carta: carta(ascendente: 250.0));
      for (var i = 1; i < oggi.length; i++) {
        expect(oggi[i].orbe, greaterThanOrEqualTo(oggi[i - 1].orbe));
      }
    });
  });

  group('Senza carta natale non si finge', () {
    test('il cielo essenziale non produce nessun aspetto', () {
      final essenziale =
          NatalChart.essential(sunSign: Zodiac.leo, hasTime: false);
      expect(essenziale.isEssential, isTrue);
      expect(
        AspettiDiOggi.perIlGiorno(
            adesso: DateTime(2026, 8, 4), carta: essenziale),
        isEmpty,
        reason: 'aspetti costruiti su una carta che non esiste',
      );
      expect(AspettiDiOggi.livello(essenziale),
          LivelloPersonalizzazione.soloSegno);
    });

    test('senza carta del tutto non produce nessun aspetto', () {
      expect(
        AspettiDiOggi.perIlGiorno(adesso: DateTime(2026, 8, 4), carta: null),
        isEmpty,
      );
      expect(AspettiDiOggi.livello(null), LivelloPersonalizzazione.soloSegno);
    });

    test('il livello raggiungibile dice la verita\' sulla carta che c\'e\'', () {
      expect(AspettiDiOggi.livello(carta()),
          LivelloPersonalizzazione.cartaSenzaOra);
      expect(AspettiDiOggi.livello(carta(ascendente: 250.0)),
          LivelloPersonalizzazione.cartaCompleta);
    });

    test('l\'Ascendente entra negli aspetti solo se c\'e\' l\'ora', () {
      final transiti = {CorpoCeleste.sole: 250.0};
      final conOra =
          AspettiDiOggi.fra(transiti: transiti, carta: carta(ascendente: 250.0));
      final senzaOra = AspettiDiOggi.fra(transiti: transiti, carta: carta());
      expect(conOra.any((a) => a.bId == AspettiDiOggi.idAscendente), isTrue);
      expect(senzaOra.any((a) => a.bId == AspettiDiOggi.idAscendente), isFalse);
    });
  });

  group('Quante porte arrivano all\'Oroscopo', () {
    test('nessuna porta nuova legge il corpus alle spalle di Horoscope', () {
      // Le porte note al 4 agosto 2026. Chi ne apre una nuova deve dichiararla
      // qui, altrimenti l'ordine 2 di 2 la lascera' fuori e quell'angolo
      // continuera' a mostrare il testo vecchio.
      // Era due. La card da condividere si rileggeva il corpus per conto suo,
      // ed e' stata chiusa: adesso prende la sintesi dalla scheda che riceve.
      // Ne resta UNA, ed e' la porta buona.
      const porteDichiarate = {
        'lib/core/horoscope/horoscope.dart',
      };

      final chiLegge = <String>{};
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final percorso = f.path.replaceAll(r'\', '/');
        if (percorso.endsWith('lib/core/horoscope/horoscope_data.dart')) {
          continue;
        }
        if (f.readAsStringSync().contains('HoroscopeData.')) {
          chiLegge.add(percorso.substring(percorso.indexOf('lib/')));
        }
      }

      expect(chiLegge, porteDichiarate,
          reason: 'le porte dell\'Oroscopo sono cambiate: chi legge il corpus '
              'adesso e\' $chiLegge');
    });

    test('l\'hash e\' ancora al suo posto come ripiego', () {
      // Non si toglie in quest\'ordine: toglierlo adesso lascerebbe le schede
      // vuote, perche' il testo nuovo non esiste ancora.
      final testo =
          File('lib/core/horoscope/horoscope.dart').readAsStringSync();
      expect(testo.contains('_fnv1a'), isTrue,
          reason: 'l\'hash e\' stato tolto prima che ci fosse il testo nuovo');
    });
  });
}

/// La firma di un elenco di aspetti, per confrontarne due.
String _firma(List<ChartAspect> aspetti) => aspetti
    .map((a) => '${a.aId}|${a.bId}|${a.type.name}|${a.orbe.toStringAsFixed(3)}')
    .join(';');
