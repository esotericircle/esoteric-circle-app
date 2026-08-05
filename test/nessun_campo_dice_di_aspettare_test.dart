import 'dart:io';

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:flutter_test/flutter_test.dart';

/// NESSUN CAMPO DICE PIU' CHE ASPETTA QUALCOSA.
///
/// **Il difetto, visto sul telefono.** Nella scheda piena del Rito dell'Alba i
/// campi "Transito attivo oggi" e "Nella tradizione" mostravano tutti e due la
/// stessa frase: "In attesa dei contenuti astrologici verificati". Non era un
/// contenuto, era l'impalcatura dell'app messa sotto gli occhi di chi la usa.
///
/// Le due regole che questo file sorveglia:
///
/// 1. nessun testo mostrato contiene una frase d'attesa, su TUTTI i riti e per
///    tutti e tre i Maestri, non su un campione;
/// 2. il transito viene dal MOTORE e non da una costante: cambia con la carta
///    natale e cambia col giorno, e senza carta non c'e' proprio.
void main() {
  /// Una carta completa, con le case: senza ora di nascita i transiti sui
  /// pianeti ci sono lo stesso, ma qui serve il caso pieno.
  NatalChart carta({required double sole, required double ascendente}) =>
      NatalChart(
        sunSign: Zodiac.leo,
        planets: [
          PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: sole,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'moon',
              name: 'Luna',
              glyph: '☽',
              longitude: (sole + 97.3) % 360,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'venus',
              name: 'Venere',
              glyph: '♀',
              longitude: (sole + 21.8) % 360,
              sign: Zodiac.leo),
        ],
        ascendantLongitude: ascendente,
        midheavenLongitude: (ascendente + 270) % 360,
        houses: [
          for (var n = 1; n <= 12; n++)
            HouseCusp(
                number: n, longitude: (ascendente + (n - 1) * 30.0) % 360.0),
        ],
        hasTime: true,
      );

  final unaCarta = carta(sole: 128.4, ascendente: 205.0);
  final altraCarta = carta(sole: 311.2, ascendente: 42.0);

  group('VOCE 1. Nessuna frase d\'attesa, su tutti i riti', () {
    test('Nessun testo mostrato dice di aspettare, su un anno intero', () {
      // ENUMERATA, non a campione: trecentosessantacinque giorni per tre
      // Maestri, con carta e senza. La rotazione dei Maestri e' su tre, quindi
      // un anno le attraversa tutte e nove le forme del rito piu' volte.
      const attese = [
        'in attesa',
        'arriverà dai contenuti',
        'arrivera\' dai contenuti',
        'non ancora disponibile',
        'prossimamente',
        'coming soon',
        'da definire',
        'segnaposto',
      ];
      var guardati = 0;
      for (var g = 0; g < 365; g++) {
        final giorno = DateTime.utc(2026, 1, 1).add(Duration(days: g));
        for (final conCarta in [true, false]) {
          final dono = DawnGift.forChart(giorno,
              carta: conCarta ? unaCarta : null);
          final mostrati = <String?>[
            dono.source.natalDescription,
            dono.source.transit,
            dono.source.tradition,
            dono.orientation,
            dono.word,
            dono.kind.label,
          ];
          for (final t in mostrati) {
            if (t == null) continue;
            guardati++;
            final basso = t.toLowerCase();
            for (final a in attese) {
              expect(basso.contains(a), isFalse,
                  reason: '${giorno.toIso8601String().substring(0, 10)}, '
                      'carta $conCarta: un testo mostrato dice "$a". «$t»');
            }
          }
        }
      }
      expect(guardati, greaterThan(2000),
          reason: 'questa prova ha guardato solo $guardati testi: con cosi\' '
              'pochi non sta enumerando niente');
    });

    test('NESSUNA FRASE D\'ATTESA scritta nelle stringhe dei riti', () {
      // **QUESTA PROVA NASCE DA UN ROSSO RESTATO VERDE.** La prova qui sopra
      // enumera il MODELLO, cioe' `DawnGift`, e non vede niente di quello che
      // la scheda scrive per conto suo: rimettendo il segnaposto dentro
      // `ritual_gift_card.dart` come letterale, tutte e sette le prove
      // restavano verdi. Un testo mostrato puo' nascere anche dove il modello
      // non arriva, e allora si guarda la sorgente di chi lo mostra.
      const attese = [
        'In attesa',
        'in attesa',
        'arriverà dai contenuti',
        'Prossimamente',
        'Coming soon',
        'segnaposto',
      ];
      final colpevoli = <String>[];
      for (final f in Directory('lib/features/rituals')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        // I COMMENTI NON SONO TESTI MOSTRATI. Questo file racconta nelle sue
        // intestazioni quale frase e' stata tolta, e contarla sarebbe contare
        // il racconto della correzione come se fosse il difetto.
        final vive = f.readAsLinesSync().where((r) {
          final t = r.trimLeft();
          return !t.startsWith('//') && !t.startsWith('///') &&
              !t.startsWith('*');
        });
        for (final riga in vive) {
          for (final a in attese) {
            if (riga.contains("'") && riga.contains(a)) {
              colpevoli.add('${f.uri.pathSegments.last}: ${riga.trim()}');
            }
          }
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'queste righe scrivono una frase d\'attesa dentro una '
              'stringa mostrata:\n${colpevoli.join("\n")}');
    });

    test('I tre Maestri ci passano tutti, e la rotazione li tocca tutti', () {
      // Il guardiano dell'altra: se la rotazione ne saltasse uno, l'anno
      // intero non sarebbe un anno intero.
      final visti = <Maestro>{};
      for (var g = 0; g < 365; g++) {
        visti.add(
            DailyRituals.dawnMaestro(DateTime.utc(2026, 1, 1).add(Duration(days: g))));
      }
      expect(visti.length, Maestro.values.length,
          reason: 'la rotazione tocca ${visti.length} Maestri su '
              '${Maestro.values.length}');
    });
  });

  group('VOCE 1b. Il transito viene dal motore, non da una costante', () {
    test('Senza carta natale il transito NON C\'E\', e la riga sparisce', () {
      final dono = DawnGift.forChart(DateTime.utc(2026, 8, 5), carta: null);
      expect(dono.source.transit, isNull,
          reason: 'senza ora e luogo di nascita non ci sono transiti sulla '
              'carta: dirne uno sarebbe inventarlo');
    });

    test('DUE CARTE DIVERSE, due transiti diversi nello stesso giorno', () {
      final giorno = DateTime.utc(2026, 8, 5);
      final uno = DawnGift.forChart(giorno, carta: unaCarta).source.transit;
      final due = DawnGift.forChart(giorno, carta: altraCarta).source.transit;
      expect(uno, isNotNull);
      expect(due, isNotNull);
      expect(uno, isNot(due),
          reason: 'due persone con carte natali diverse leggono lo stesso '
              'transito: allora non viene dalla loro carta. «$uno»');
    });

    test('LO STESSO GIORNO non cambia, un altro giorno si', () {
      final oggi = DateTime.utc(2026, 8, 5, 6);
      expect(DawnGift.forChart(oggi, carta: unaCarta).source.transit,
          DawnGift.forChart(oggi, carta: unaCarta).source.transit,
          reason: 'due letture nella stessa mattina danno due transiti');
      final poi = DateTime.utc(2026, 11, 17, 6);
      expect(DawnGift.forChart(oggi, carta: unaCarta).source.transit,
          isNot(DawnGift.forChart(poi, carta: unaCarta).source.transit),
          reason: 'tre mesi dopo il cielo dice la stessa identica cosa');
    });

    test('Il transito NOMINA un corpo e un punto della carta', () {
      final t = DawnGift.forChart(DateTime.utc(2026, 8, 5), carta: unaCarta)
          .source
          .transit!;
      expect(t, contains('di nascita'),
          reason: 'il transito non nomina nessun punto natale: «$t»');
      expect(t.length, greaterThan(30),
          reason: 'il transito e\' lungo ${t.length} caratteri: sembra una '
              'costante, non una frase composta. «$t»');
      stdout.writeln('IL TRANSITO DI PROVA: «$t»');
    });

    test('La fonte nella tradizione e\' nulla, e per una ragione scritta', () {
      // Non e' un'attesa: e' una dichiarazione. I nove riti dell'Alba sono
      // composti dal progetto, e per nessuno esiste oggi una fonte verificata
      // da citare. Il giorno in cui arrivera' entrera' in
      // `FormaDelRito.fonte`, e questa prova andra' riscritta con lei.
      for (var g = 0; g < 30; g++) {
        final dono = DawnGift.forChart(
            DateTime.utc(2026, 8, 5).add(Duration(days: g)),
            carta: unaCarta);
        expect(dono.source.tradition, isNull,
            reason: 'una fonte e\' comparsa senza che nessuno l\'abbia '
                'verificata: «${dono.source.tradition}»');
      }
      final sorgente =
          File('lib/core/rituals/dawn_gift.dart').readAsStringSync();
      expect(sorgente.contains('FormaDelRito.fonte'), isTrue,
          reason: 'il codice non dice piu\' DOVE entrera\' la fonte quando '
              'arrivera\', quindi il prossimo che passa la rimette come '
              'segnaposto');
    });
  });
}
